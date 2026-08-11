import { createRoot, type Root } from "react-dom/client";
import { App } from "./App";
import styles from "./styles.css?inline";

class ForgeApp extends HTMLElement {
  private root?: Root;
  connectedCallback() {
    const mount = document.createElement("div");
    const shadow = this.attachShadow({ mode: "open" });
    const style = document.createElement("style");
    style.textContent = styles;
    shadow.append(style, mount);
    const apiBase = this.getAttribute("api-base") || "/api/v1";
    this.root = createRoot(mount);
    this.root.render(<App apiBase={apiBase} />);
  }
  disconnectedCallback() { this.root?.unmount(); }
}
customElements.define("forge-app", ForgeApp);
