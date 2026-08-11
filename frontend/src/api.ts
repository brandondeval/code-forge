export type Repository = { id: number; name: string; description: string | null; visibility: string; stars_count: number; imported_files_count: number; open_issues_count: number; open_pull_requests_count: number; owner: { login: string } };
export type Account = { user: { id: number; login: string; email: string | null }; repositories: Repository[] };

export async function repositories(apiBase: string): Promise<Repository[]> {
  const response = await fetch(`${apiBase}/repositories`);
  if (!response.ok) throw new Error("Could not load repositories");
  return response.json();
}

export async function createRepository(
  apiBase: string,
  token: string,
  repository: { name: string; description: string; visibility: "public" | "private" }
): Promise<Repository> {
  const response = await fetch(`${apiBase}/repositories`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
    body: JSON.stringify({ repository })
  });
  const payload = await response.json();
  if (!response.ok) throw new Error(payload.errors?.join(", ") || payload.error || "Could not create repository");
  return payload;
}

export async function account(apiBase: string, token: string): Promise<Account> {
  const response = await fetch(`${apiBase}/account`, { headers: { Authorization: `Bearer ${token}` } });
  const payload = await response.json();
  if (!response.ok) throw new Error(payload.error || "Could not load account");
  return payload;
}

export async function publicAccount(apiBase: string, login: string, token?: string): Promise<Account> {
  const headers = token ? { Authorization: `Bearer ${token}` } : undefined;
  const response = await fetch(`${apiBase}/users/${encodeURIComponent(login)}`, { headers });
  const payload = await response.json();
  if (!response.ok) throw new Error(payload.error || "Could not load account");
  return payload;
}

export function importRepository(apiBase: string, token: string, repository: { name: string; description: string; visibility: "public" | "private" }, files: FileList | null, archive: File | null, onProgress: (percent: number, state: "uploading" | "processing") => void): Promise<Repository> {
  const body = new FormData();
  body.append("repository[name]", repository.name); body.append("repository[description]", repository.description); body.append("repository[visibility]", repository.visibility);
  Array.from(files || []).forEach((file) => { body.append("files[]", file); body.append("paths[]", file.webkitRelativePath || file.name); });
  if (archive) body.append("archive", archive);
  return new Promise((resolve, reject) => {
    const request = new XMLHttpRequest();
    request.open("POST", `${apiBase}/repository_imports`); request.setRequestHeader("Authorization", `Bearer ${token}`);
    request.upload.onprogress = (event) => { if (event.lengthComputable) onProgress(Math.round((event.loaded / event.total) * 95), "uploading"); };
    request.upload.onload = () => onProgress(95, "processing");
    request.onerror = () => reject(new Error("Network error while uploading repository"));
    request.onload = () => { const payload = JSON.parse(request.responseText || "{}"); request.status >= 200 && request.status < 300 ? resolve(payload) : reject(new Error(payload.errors?.join(", ") || payload.error || "Could not import repository")); };
    request.send(body);
  });
}

type AuthResponse = { access_token: string; token_type: "Bearer"; user: { id: number; login: string; email: string | null } };

export async function authenticate(apiBase: string, mode: "sign-in" | "register", values: { login: string; email?: string; password: string; passwordConfirmation?: string }): Promise<AuthResponse> {
  const endpoint = mode === "register" ? "oauth/register" : "oauth/token";
  const body = mode === "register"
    ? { user: { login: values.login, email: values.email, password: values.password, password_confirmation: values.passwordConfirmation } }
    : { login: values.login, password: values.password, grant_type: "password" };
  const response = await fetch(`${apiBase.replace(/\/api\/v1$/, "")}/${endpoint}`, { method: "POST", credentials: "include", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
  const payload = await response.json();
  if (!response.ok) throw new Error(payload.errors?.join(", ") || payload.error || "Authentication failed");
  return payload;
}

export async function establishBrowserSession(apiBase: string, token: string): Promise<void> {
  const response = await fetch(`${apiBase.replace(/\/api\/v1$/, "")}/oauth/session`, {
    method: "POST",
    credentials: "include",
    headers: { Authorization: `Bearer ${token}` }
  });
  if (!response.ok) throw new Error("Could not establish browser session");
}

export async function endBrowserSession(apiBase: string): Promise<void> {
  await fetch(`${apiBase.replace(/\/api\/v1$/, "")}/oauth/logout`, { method: "POST", credentials: "include" });
}

export async function resetPassword(apiBase: string, values: { login: string; password: string; passwordConfirmation: string }): Promise<void> {
  const response = await fetch(`${apiBase.replace(/\/api\/v1$/, "")}/oauth/forgot_password`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ login: values.login, password: values.password, password_confirmation: values.passwordConfirmation }) });
  const payload = await response.json();
  if (!response.ok) throw new Error(payload.errors?.join(", ") || payload.error || "Could not reset password");
}
