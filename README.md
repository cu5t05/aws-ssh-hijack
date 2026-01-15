# SSH Agent Hijacking: How Reliance on Bastions Undermines Enterprise Security

This repository hosts the final project report **“SSH Agent Hijacking: How Reliance on Bastions Undermines Enterprise Security”**, authored by Cuong Nguyen, Hasina Belton, Jabriel Roberts, Tanvin Farjana, and Tazahanae Matthews.  

The report analyzes how strong, cloud-native authentication practices (Amazon Cognito Hosted UI with Authorization Code + PKCE, CloudFront OAC, and AWS WAF) can still be undermined by legacy operational patterns such as shared bastion hosts with SSH agent forwarding.

---

## Abstract

In a controlled lab environment, a lower-privileged user on a shared bastion host was able to interact with an administrator’s forwarded SSH agent. This enabled authentication to private EC2 instances as the administrator **without ever possessing or exfiltrating private key material**.  

The attack chain maps to MITRE ATT&CK techniques including:

- **T1563.001** Remote Service Session Hijacking (SSH)  
- **T1021.004** Remote Services (SSH)  
- **T1078** Valid Accounts  
- **T1098.004** Account Manipulation (SSH Authorized Keys, potential persistence)

---

## Key Findings

- Strong web authentication (Cognito Hosted UI + PKCE) remains intact, but operational identity can still be hijacked through agent forwarding.
- A lower-privileged bastion user achieved administrator-level access on private hosts without key theft.
- Detection opportunities exist at bastion, host, and control plane levels — but require deliberate log collection and correlation.

---

## Mitigations

- **Disable SSH agent forwarding** in all workflows.  
- **Replace bastions with identity-aware access**, such as AWS Systems Manager Session Manager.  
- Use **short-lived SSH certificates** and **hardware-backed keys** (FIDO2, YubiKey).  
- Apply **network segmentation** to reduce east-west movement.  
- Strengthen **policy, training, and governance** to prohibit legacy trust patterns.  
- Build **detection engineering** around agent misuse and unexpected session provenance.

---

## Compliance Mapping

- **NIST CSF**: Strengthens access control, monitoring, and mitigation categories.  
- **SOC 2**: Aligns with CC6 (Logical Access Controls) and CC7 (Change Management and Monitoring).  
- Produces audit-friendly evidence by centralizing identity and session records.

---

## Ethical Considerations

- All testing was performed in a controlled lab with synthetic accounts and systems.  
- No real user data was accessed.  
- Exploit details were excluded to maintain focus on architecture-level lessons.  

---

## Author

- Cuong Nguyen  

---

## References

- [MITRE ATT&CK T1563.001: SSH Hijacking](https://attack.mitre.org/techniques/T1563/001/)  
- [MITRE ATT&CK T1021.004: Remote Services (SSH)](https://attack.mitre.org/techniques/T1021/004/)  
- [AWS Cognito Hosted UI](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-userpools-app-idp-settings.html)  
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)  

---


