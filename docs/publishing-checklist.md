# Publication and quality checklist

Use this checklist **before** making the repository public.

- [ ] Read the ten Markdown case studies and correct any mismatch with the saved ServiceNow screenshots.
- [ ] Confirm Incident 08 final state On Hold — Awaiting Change, with no approved change claimed.
- [ ] Confirm Incident 09 is a standalone `SCTASK0010001`; Requested for was blank after save.
- [ ] Confirm Incident 10 is On Hold — Awaiting Problem; Wazuh event ingestion remains unverified.
- [ ] Review every proposed screenshot: hide passwords, tokens, recovery codes, email addresses, tenant IDs, browser tabs and profile details not needed for the demonstration.
- [ ] Consider masking VM names, username details, private IPs and Active Directory identifiers as appropriate for public disclosure.
- [ ] Never upload `.ovpn`, `.key`, `.pem`, certificates with private keys, `.env`, configuration backups, `known_hosts`, credential exports, database dumps, or raw event archives.
- [ ] Add only explicitly reviewed images to `evidence/reviewed/`; update case studies with relative links for screenshots actually present.
- [ ] Test links in README and confirm the Mermaid diagram renders on GitHub.
- [ ] Make clear all characters and ticket narratives are fictional; some commands, outcomes and measurements are real isolated-lab observations.
- [ ] Check the final git diff and GitHub repository visibility before making the first push.

## Deployment from Windows (Git)

1. Create a **new empty repository** named `Northstar-ServiceNow-HelpDesk-Lab-2026` under `chadibazzi` on GitHub (do not add a README during creation).
2. Extract the ZIP into a working folder on the host PC. Verify files first.
3. In PowerShell inside the extracted folder, run:

```powershell
git init
git add .
git status
git commit -m "Initial Northstar Help Desk lab portfolio"
git branch -M main
git remote add origin https://github.com/chadibazzi/Northstar-ServiceNow-HelpDesk-Lab-2026.git
git push -u origin main
```

The `git push` command requires GitHub authentication and repository creation first. **Do not enter credentials or tokens into chat**. If Git is not installed, GitHub's website upload interface can be used for the extracted files instead.
