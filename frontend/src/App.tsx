import { FormEvent, useEffect, useState } from "react";
import { account, authenticate, createRepository, endBrowserSession, establishBrowserSession, importRepository, publicAccount, repositories, resetPassword, type Account, type Repository } from "./api";
import "./styles.css";

export function App({ apiBase }: { apiBase: string }) {
  const [items, setItems] = useState<Repository[]>([]);
  const [accountDetails, setAccountDetails] = useState<Account | null>(null);
  const initialLogin = window.location.pathname.match(/^\/users\/([^/]+)$/)?.[1] || null;
  const [screen, setScreen] = useState<"explore" | "account">(initialLogin ? "account" : "explore");
  const [accountLogin, setAccountLogin] = useState<string | null>(initialLogin);
  const [error, setError] = useState("");
  const [showRepositoryForm, setShowRepositoryForm] = useState(false);
  const [showUploadForm, setShowUploadForm] = useState(false);
  const [showAuth, setShowAuth] = useState(false);
  const [authMode, setAuthMode] = useState<"sign-in" | "register" | "forgot-password">("sign-in");
  const [busy, setBusy] = useState(false);
  const [uploadStatus, setUploadStatus] = useState<{ percent: number; state: "uploading" | "processing" } | null>(null);
  const [token, setToken] = useState(() => localStorage.getItem("forge-access-token") || "");

  useEffect(() => { repositories(apiBase).then(setItems).catch((e: Error) => setError(e.message)); }, [apiBase]);
  useEffect(() => { if (token) void establishBrowserSession(apiBase, token).catch(() => undefined); }, [apiBase, token]);
  useEffect(() => {
    const onPopState = () => { const login = window.location.pathname.match(/^\/users\/([^/]+)$/)?.[1] || null; setAccountLogin(login); setScreen(login ? "account" : "explore"); };
    window.addEventListener("popstate", onPopState); return () => window.removeEventListener("popstate", onPopState);
  }, []);
  useEffect(() => { if (screen === "account" && accountLogin) loadAccount(accountLogin); }, [screen, accountLogin, token]);

  async function loadAccount(login: string) {
    try { setAccountDetails(null);
      const ownLogin = localStorage.getItem("forge-login");
      setAccountDetails(token && ownLogin === login ? await account(apiBase, token) : await publicAccount(apiBase, login, token));
    } catch (e) { setError(e instanceof Error ? e.message : "Could not load account"); }
  }
  function goToAccount(login: string) { window.history.pushState({}, "", `/users/${encodeURIComponent(login)}`); setAccountLogin(login); setScreen("account"); }
  function goToExplore() { window.history.pushState({}, "", "/"); setScreen("explore"); }
  async function signOut() { try { await endBrowserSession(apiBase); } finally { localStorage.removeItem("forge-access-token"); localStorage.removeItem("forge-login"); setToken(""); setAccountDetails(null); setShowRepositoryForm(false); setShowUploadForm(false); goToExplore(); } }
  async function beginAccount() { if (!token) return setShowAuth(true); try { const details = await account(apiBase, token); localStorage.setItem("forge-login", details.user.login); setAccountDetails(details); goToAccount(details.user.login); } catch (e) { setError(e instanceof Error ? e.message : "Could not load account"); } }
  async function submitAuth(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const form = new FormData(event.currentTarget); setError(""); setBusy(true);
    try { if (authMode === "forgot-password") { await resetPassword(apiBase, { login: String(form.get("login")), password: String(form.get("password")), passwordConfirmation: String(form.get("password_confirmation")) }); setAuthMode("sign-in"); setError("Password updated. Sign in with your new password."); return; } const result = await authenticate(apiBase, authMode, { login: String(form.get("login")), email: String(form.get("email") || ""), password: String(form.get("password")), passwordConfirmation: String(form.get("password_confirmation") || "") }); localStorage.setItem("forge-access-token", result.access_token); localStorage.setItem("forge-login", result.user.login); setToken(result.access_token); setShowAuth(false); goToAccount(result.user.login); }
    catch (e) { setError(e instanceof Error ? e.message : "Authentication failed"); } finally { setBusy(false); }
  }
  async function create(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const form = new FormData(event.currentTarget); setBusy(true); setError("");
    try { const repo = await createRepository(apiBase, token, { name: String(form.get("name")), description: String(form.get("description")), visibility: String(form.get("visibility")) as "public" | "private" }); setItems((current) => [repo, ...current]); setShowRepositoryForm(false); if (screen === "account" && accountLogin) await loadAccount(accountLogin); }
    catch (e) { setError(e instanceof Error ? e.message : "Could not create repository"); } finally { setBusy(false); }
  }
  async function upload(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const formElement = event.currentTarget; const form = new FormData(formElement); const files = (formElement.elements.namedItem("files") as HTMLInputElement).files; const archive = (formElement.elements.namedItem("archive") as HTMLInputElement).files?.[0] || null; setBusy(true); setError(""); setUploadStatus({ percent: 0, state: "uploading" });
    try { if (!files?.length && !archive) throw new Error("Choose a local repository folder or ZIP archive first"); const repo = await importRepository(apiBase, token, { name: String(form.get("name")), description: String(form.get("description")), visibility: String(form.get("visibility")) as "public" | "private" }, files, archive, (percent, state) => setUploadStatus({ percent, state })); setUploadStatus({ percent: 100, state: "processing" }); setItems((current) => [repo, ...current]); setShowUploadForm(false); if (accountLogin) await loadAccount(accountLogin); }
    catch (e) { setError(e instanceof Error ? e.message : "Could not upload repository"); } finally { setBusy(false); setUploadStatus(null); }
  }
  const repositoryForm = <form className="new-repository" onSubmit={create}><h3>New repository</h3><label>Repository name<input name="name" required pattern="[a-zA-Z0-9._-]+" placeholder="my-project" /></label><label>Description<textarea name="description" /></label><label>Visibility<select name="visibility" defaultValue="public"><option value="public">Public</option><option value="private">Private</option></select></label><div className="form-actions"><button type="button" onClick={() => setShowRepositoryForm(false)}>Cancel</button><button className="primary" disabled={busy}>Create repository</button></div></form>;
  const uploadForm = <form className="new-repository" onSubmit={upload}><h3>Upload local Git repository</h3><p className="hint">Choose a repository folder or a ZIP archive. Forge imports the selected working-tree files.</p><label>Repository name<input name="name" required pattern="[a-zA-Z0-9._-]+" placeholder="my-project" /></label><label>Description<textarea name="description" /></label><label>Repository folder<input name="files" type="file" multiple webkitdirectory="" /></label><label>or ZIP archive<input name="archive" type="file" accept=".zip,application/zip" /></label><label>Visibility<select name="visibility" defaultValue="private"><option value="private">Private</option><option value="public">Public</option></select></label>{uploadStatus && <div className="upload-progress" role="status"><span className="spinner" /> <strong>{uploadStatus.state === "uploading" ? `Uploading ${uploadStatus.percent}%` : "Processing repository…"}</strong><div className="progress-track"><div style={{ width: `${uploadStatus.percent}%` }} /></div></div>}<div className="form-actions"><button type="button" disabled={busy} onClick={() => setShowUploadForm(false)}>Cancel</button><button className="primary" disabled={busy}>{busy ? "Uploading…" : "Upload repository"}</button></div></form>;
  const canManageAccount = Boolean(token && accountDetails?.user.login === localStorage.getItem("forge-login"));
  return <main className="forge-shell"><header><strong>◈ Forge</strong><nav><button className="nav-link" onClick={goToExplore}>Explore</button> · Issues · Pull requests</nav><button className="account-icon" onClick={beginAccount} title="Your account">{accountDetails?.user.login?.slice(0, 1).toUpperCase() || "●"}</button></header>{screen === "explore" ? <section><div className="hero"><p>Code, collaborate, ship.</p><h1>Build together.</h1><span>A composable GitHub-style product foundation.</span></div><div className="content"><div className="section-heading"><h2>Popular repositories</h2>{token && <button className="primary" onClick={() => setShowRepositoryForm(true)}>New repository</button>}</div>{showRepositoryForm && repositoryForm}<RepositoryList repositories={items} /></div></section> : <section className="content account-page"><button className="nav-link" onClick={goToExplore}>← Explore repositories</button>{accountDetails ? <><div className="account-heading"><div className="account-avatar">{accountDetails.user.login.slice(0, 1).toUpperCase()}</div><div><h1>{accountDetails.user.login}</h1><p>{accountDetails.user.email || "Forge account"}</p></div>{canManageAccount && <button className="sign-out" onClick={signOut}>Sign out</button>}</div><div className="section-heading"><h2>{canManageAccount ? "Your repositories" : `${accountDetails.user.login}'s repositories`}</h2>{canManageAccount && <div className="account-actions"><button onClick={() => setShowUploadForm(true)}>Upload repository</button><button className="primary" onClick={() => setShowRepositoryForm(true)}>New repository</button></div>}</div>{canManageAccount && showRepositoryForm && repositoryForm}{canManageAccount && showUploadForm && uploadForm}<RepositoryList repositories={accountDetails.repositories} /></> : <p>Loading account…</p>}</section>}{showAuth && <div className="dialog"><form className="new-repository" onSubmit={submitAuth}><h3>{authMode === "sign-in" ? "Sign in" : authMode === "register" ? "Create account" : "Reset password"}</h3><label>Login or email<input name="login" required /></label>{authMode === "register" && <label>Email<input name="email" type="email" /></label>}<label>{authMode === "forgot-password" ? "New password" : "Password"}<input name="password" type="password" required /></label>{authMode !== "sign-in" && <label>Confirm password<input name="password_confirmation" type="password" required /></label>}{authMode === "forgot-password" && <p className="hint">For local development, this reset does not verify account ownership.</p>}<div className="form-actions"><button type="button" onClick={() => setAuthMode(authMode === "sign-in" ? "register" : "sign-in")}>{authMode === "sign-in" ? "Create account" : "I have an account"}</button>{authMode === "sign-in" && <button type="button" onClick={() => setAuthMode("forgot-password")}>Forgot password?</button>}<button className="primary" disabled={busy}>{authMode === "sign-in" ? "Sign in" : authMode === "register" ? "Register" : "Reset password"}</button></div></form></div>}{error && <p className="error" role="alert">{error}</p>}</main>;
}

function RepositoryList({ repositories }: { repositories: Repository[] }) {
  return <div className="repository-list">{repositories.map((repo) => <article key={repo.id}><div><a href={`http://localhost:3000/repositories/${encodeURIComponent(repo.owner.login)}/${encodeURIComponent(repo.name)}`}>{repo.owner.login}/{repo.name}</a><p>{repo.description || "No description"}</p></div><span>{repo.visibility}</span><footer>★ {repo.stars_count} · ◉ {repo.open_issues_count} issues · ⇆ {repo.open_pull_requests_count} pull requests {repo.imported_files_count > 0 && ` · ${repo.imported_files_count} imported files`}</footer></article>)}</div>;
}
