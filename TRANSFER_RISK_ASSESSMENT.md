# Transfer Risk Assessment
## Information Required by Clause 14(b) of the EU Standard Contractual Clauses

**Application:** Arcadia (com.Luziv.arcadia)  
**Data Controller:** Luziv  
**Assessment Date:** [Date]  
**Document Version:** 1.0

---

## 1. LOCATION OF COMPANY

### 1.1 Company Entity Incorporation
**Country of Incorporation:** [TO BE COMPLETED - Please specify the country where Luziv is legally incorporated]

**Example:** If incorporated in France: "France"  
If incorporated in Germany: "Germany"  
If incorporated in US: "United States of America"

### 1.2 Material Data Processing Locations
**Primary Processing Location:** User's Device (Locally)

**Company Processing Locations:**
- **[TO BE COMPLETED]** - Please specify all countries/regions where:
  - Company offices are located
  - Development team operates
  - Any servers or infrastructure are located (if applicable)

**Note:** Since Arcadia operates entirely offline, all data processing occurs on the user's device. No data is processed by company servers or infrastructure.

---

## 2. COMPANY'S PRIMARY STORAGE LOCATION OF THE DATA TRANSFERRED

### 2.1 Storage Location
**Primary Storage Location:** User's Device Only (No Company Storage)

### 2.2 Detailed Storage Information
- **Android Devices:**
  - Storage Path: `/data/data/com.Luziv.arcadia/app_flutter/`
  - Storage Type: Application sandbox (encrypted by Android File-Based Encryption)
  - Jurisdiction: Device location (varies by user)

- **iOS Devices:**
  - Storage Path: Application sandbox (Documents/Library directory)
  - Storage Type: iOS Data Protection API encrypted storage
  - Jurisdiction: Device location (varies by user)

### 2.3 Company Infrastructure
**No Company-Controlled Storage:**
- The application does not utilize any company-owned or controlled servers
- No cloud storage infrastructure
- No third-party hosting services
- All data remains exclusively on the user's device

**Data Transfer Status:** NO DATA TRANSFER OCCURS
- No personal data is transferred from the user's device to Company
- No personal data is stored on Company servers
- No personal data is transmitted over networks to Company infrastructure

---

## 3. TRANSMISSION CHANNEL USED

### 3.1 Description of Transmission Method
**Transmission Channel:** NONE

**Physical/Technological Method:** N/A - No data transmission occurs

### 3.2 Transmission Details
Since Arcadia operates entirely offline and stores all data locally on the user's device:

- **No Network Transmission:** No personal data is transmitted via:
  - Internet (HTTP/HTTPS)
  - Mobile networks (3G/4G/5G)
  - Wi-Fi networks
  - Bluetooth
  - Any other network protocols

- **No Cloud Services:** No personal data is transmitted to:
  - Cloud storage services
  - Third-party servers
  - Company servers
  - Content Delivery Networks (CDNs)

- **No API Communication:** No personal data is transmitted via:
  - REST APIs
  - GraphQL APIs
  - WebSocket connections
  - Any external API endpoints

### 3.3 Data Flow
**Data Flow Diagram:**
```
User Device (Application)
    ↓
Local Storage (Hive Database)
    ↓
Application Memory (Runtime)
    ↓
User Device (No external transmission)
```

**Conclusion:** Personal data does not leave the user's device at any point. There is no data transmission channel because there is no data transfer.

---

## 4. LOCAL LAWS REQUIRING DISCLOSURE TO PUBLIC AUTHORITIES

### 4.1 Company's Subject Jurisdiction
**Question 4(a): Is Company subject to any local laws that can require Company to disclose personal data to public authorities or authorise access by public authorities, e.g. FISA 702 in the US?**

**Answer:** [TO BE COMPLETED BASED ON COMPANY JURISDICTION]

#### If Company is incorporated in the European Union/EEA:
**No Applicable Laws Requiring Disclosure:**
- The Company is subject to EU/EEA data protection laws (GDPR) which generally prohibit disclosure of personal data to public authorities except in limited circumstances
- No equivalent laws to FISA 702 exist in the EU/EEA
- Any disclosure would require proper legal basis under GDPR (Article 6) and judicial authorization where required
- EU Member States have laws allowing government access, but these are subject to strict safeguards, judicial oversight, and proportionality requirements

**Relevant Laws (if applicable in EU Member State):**
- National security laws of the EU Member State where Company is incorporated
- Law enforcement cooperation laws
- All subject to GDPR requirements and judicial oversight

#### If Company is incorporated in the United States:
**Potential Applicable Laws:**
- **FISA 702** (Foreign Intelligence Surveillance Act Section 702) - May apply if Company is a US entity, subject to certain thresholds
- **FISA Title I** - Court orders for electronic surveillance
- **National Security Letters (NSLs)** - Under Patriot Act
- **Cloud Act** - If Company is a US service provider
- **Executive Order 12333** - For intelligence gathering

**Note:** Since Arcadia operates entirely offline and stores no data on Company servers, the practical risk of government access is minimal even if Company is US-based, as there is no data under Company's control to access.

#### If Company is incorporated in another jurisdiction:
**Please specify applicable laws:**
- [List relevant laws of the jurisdiction where Company is incorporated]

---

### 4.2 Past Requests from Public Authorities
**Question 4(b): Subject to any legal prohibitions on disclosing this information, has Company received any requests from any public authority to disclose personal data under such local laws referenced in 4(a), in the past five years?**

**Answer:** [TO BE COMPLETED]

#### Standard Response Options:

**Option 1 - No Requests Received:**
"To the best of Company's knowledge, and subject to any legal prohibitions on disclosure (including gag orders or national security restrictions), Company has not received any requests from public authorities to disclose personal data under the laws referenced in section 4(a) in the past five years."

**Option 2 - Unable to Disclose:**
"Company may be legally prohibited from disclosing whether it has received such requests, particularly under national security laws or gag orders. Company will comply with all applicable legal requirements while respecting data protection principles."

**Option 3 - No Data to Disclose:**
"Even if requests were received, Company would have no personal data to disclose as Arcadia operates entirely offline and stores all data exclusively on users' devices. Company has no access to, possession of, or control over user data."

---

## 5. COMPANY'S INTENTION FOR ONWARD TRANSFER

### 5.1 Onward Transfer Assessment
**Estimated Number of Further Recipients:** ZERO (0)

**Processing Chain Length:** N/A (No processing chain exists)

### 5.2 Detailed Onward Transfer Information

#### Current State:
- **No Onward Transfers:** Company does not and will not transfer personal data to any third parties, sub-processors, or other recipients
- **No Processing Chain:** There is no processing chain as Company does not process personal data - all processing occurs locally on the user's device

#### Third-Party Services Used:
**Analytics Services:** None  
**Cloud Storage:** None  
**Authentication Services:** None  
**Advertising Services:** None  
**Crash Reporting:** None  
**Customer Support Platforms:** None (if support is needed, data would only be shared with user's explicit consent)

#### Sub-Processors:
**No Sub-Processors:** Company does not engage any sub-processors for processing personal data because:
1. No personal data is transferred to Company
2. All data processing occurs locally on user devices
3. No third-party services process user data

### 5.3 Future Onward Transfer Policy
**Commitment:** Company commits that:
- No personal data will be transferred to third parties without:
  - User's explicit consent
  - Clear disclosure in privacy policy
  - Appropriate data protection agreements (DPAs/SCCs) if transfers occur
  - Compliance with GDPR requirements

**Data Minimization:** Company will maintain its policy of minimal data collection and local-only storage to the greatest extent possible.

### 5.4 Processing Chain Details
**Processing Chain Length:** 0 (No chain - data never leaves user device)

**Processing Chain Diagram:**
```
User Device (Local Processing)
    ↓
Application (In-Memory Processing)
    ↓
Local Storage (Hive Database)
    ↓
User Device (No External Step)
```

**Recipients in Processing Chain:** NONE
- Step 1: User Device - Application runtime (local)
- Step 2: User Device - Local storage (local)
- No external steps, no third parties, no onward transfers

---

## 6. SAFEGUARDS AGAINST INTERCEPTION OR DISPROPORTIONATE ACCESS BY PUBLIC AUTHORITIES

This section provides details of contractual, technical, and organisational measures implemented to safeguard personal data from interception or disproportionate access by public authorities, during transmission or processing. This supplements Annex II of the EU Standard Contractual Clauses.

### 6.1 Technical Safeguards

#### 6.1.1 Encryption Measures
**Data Encryption at Rest:**
- **Android:** File-Based Encryption (FBE) using AES-256
- **iOS:** Data Protection API using AES-256
- **Key Storage:** Hardware-backed secure storage (Android Keystore / iOS Secure Enclave)
- **Protection Level:** Keys cannot be extracted even with device administrator access

**Effectiveness Against Public Authority Access:**
- Encryption keys are protected by hardware security modules
- File system encryption prevents access even if storage is physically accessed
- Device-specific encryption makes data inaccessible on other devices
- Even with legal compulsion, encrypted data without keys is inaccessible

#### 6.1.2 No Transmission - Zero Interception Risk
**Architecture Protection:**
- Application operates entirely offline
- No network transmission of any kind
- No data packets to intercept
- No communication channels to monitor

**Protection Against Interception:**
- ✅ Eliminates risk of network interception (man-in-the-middle, packet sniffing)
- ✅ No transmission means no interception opportunity
- ✅ No metadata that could be analyzed
- ✅ No network traffic patterns to observe

#### 6.1.3 Application Sandbox Isolation
**Implementation:**
- **Android:** SELinux policies and application sandbox enforced by OS
- **iOS:** Kernel-level sandboxing
- **Protection:** Even if device is compromised, sandbox prevents cross-app data access

#### 6.1.4 No Company Infrastructure
**Architecture Protection:**
- No Company servers or databases
- No cloud infrastructure
- No central repository of user data
- Company has no ability to access user data even if compelled

**Effectiveness:**
Even if public authorities requested data from Company:
- Company has no data to provide
- No infrastructure subject to search warrants
- No systems that could be compelled to disclose information
- No centralized storage that could be accessed

### 6.2 Organisational Safeguards

#### 6.2.1 Privacy-by-Design Architecture
- Application designed with privacy as fundamental principle
- Local-only processing as default (not optional)
- No data collection beyond necessary functionality
- Architecture decisions prioritize user privacy over convenience

#### 6.2.2 Data Minimization
- Only stores user preferences (non-identifying)
- No personal identifiers collected
- No behavioral tracking
- Minimal data scope reduces exposure risk

#### 6.2.3 Development Practices
- Regular security audits
- Code review processes
- Dependency updates for security patches
- Secure development lifecycle

#### 6.2.4 Access Control
- Restricted repository access
- No unauthorized staff access to code/data (as none exists on Company infrastructure)
- Staff training on privacy principles

### 6.3 Contractual Safeguards

#### 6.3.1 Privacy Policy Commitments
**Contractual Obligations to Users:**
- Public commitment to local-only storage
- Explicit statement of no data transmission
- User-facing privacy guarantees
- Legally enforceable commitments

#### 6.3.2 Terms of Service
- Contractual limitations on data use
- User rights clearly defined
- Data deletion guarantees
- Privacy commitments enforceable

#### 6.3.3 App Store Compliance
- Compliance with Google Play and Apple App Store privacy requirements
- Store policies enforce transparency
- Independent review of privacy practices

### 6.4 Protection Against Specific Threats

#### 6.4.1 Protection Against Government Surveillance Laws
**If Company is US-based:**
- **FISA 702 Protection:** No data exists on Company servers, so FISA 702 cannot access user data
- **Cloud Act Protection:** Not applicable - Company is not a service provider with user data
- **NSL Protection:** No data to disclose even if NSL received

**If Company is EU-based:**
- GDPR provides strong protections against disproportionate access
- Any access would require judicial authorization
- EU laws subject to proportionality and necessity requirements

#### 6.4.2 Protection Against Bulk Data Collection
- No data transmission means no bulk collection possible
- No centralized storage means no bulk access point
- Local-only architecture prevents bulk surveillance

#### 6.4.3 Protection Against Subpoenas/Warrants
**Company Response Scenario:**
Even if Company received legal process (subpoena, warrant, court order):
1. Company would have no user data to provide
2. No infrastructure exists that could be searched
3. No databases that could be compelled to disclose information
4. Company would respond truthfully that no data is in Company's possession

### 6.5 Layered Protection Summary

| Protection Layer | Mechanism | Protects Against |
|----------------|-----------|------------------|
| **No Data Transfer** | Offline architecture | Network interception, transmission surveillance |
| **No Company Storage** | No infrastructure | Government access requests to Company |
| **Device Encryption** | FBE/Data Protection | Physical device seizure, unauthorized access |
| **Sandbox Isolation** | OS security | Cross-app access, device compromise |
| **Minimal Data** | Data minimization | Limited scope if device accessed |
| **User Control** | Local storage | User can delete anytime |

### 6.6 Risk Mitigation Effectiveness

**Overall Risk Level:** VERY LOW

**Justification:**
1. **Architectural Protection:** No data transfer or Company storage eliminates primary risks
2. **Encryption Protection:** Device-level encryption protects against unauthorized access
3. **Isolation Protection:** Sandbox prevents cross-application access
4. **Contractual Protection:** Privacy commitments provide legal framework
5. **User Control:** Users maintain complete control over their data

**Comparison to Industry Standards:**
- More protective than cloud-based applications (no cloud exposure)
- More protective than analytics-enabled apps (no data transmission)
- Comparable to fully encrypted local-only applications
- Exceeds minimum GDPR requirements through privacy-by-design

---

## 7. RISK ASSESSMENT SUMMARY

### 7.1 Transfer Risk Level
**Risk Level:** MINIMAL TO NONE

**Justification:**
1. **No Data Transfer:** Personal data never leaves the user's device
2. **No Company Access:** Company has no access to, possession of, or control over personal data
3. **No Third-Party Recipients:** No onward transfers to any recipients
4. **Local-Only Storage:** All data stored locally with device-level encryption

### 7.2 Risk Factors
**Factors Eliminating Risk:**
- ✅ No network transmission
- ✅ No cloud storage
- ✅ No third-party processors
- ✅ No Company infrastructure storing data
- ✅ User has complete control over their data
- ✅ Data deletion is immediate and permanent (uninstall app)

**Remaining Considerations:**
- ⚠️ Company jurisdiction laws (only relevant if laws would apply to code/development, not data)
- ⚠️ App store platforms (Google Play, App Store) may have their own data practices, but these are separate from Company's data processing

### 7.3 Mitigation Measures
**Additional Safeguards (if applicable):**
- Company maintains no infrastructure that could be subject to government access requests
- Application code is open to security review (if applicable)
- Regular security audits of application code
- Privacy-by-design architecture
- Regular updates to address security vulnerabilities

---

## 8. CONCLUSION

### 8.1 Key Findings
1. **No Data Transfer Occurs:** Personal data is processed and stored exclusively on the user's device
2. **No Third-Party Transfers:** Company does not transfer data to any third parties or sub-processors
3. **No Company Storage:** Company does not store or have access to personal data
4. **Minimal Risk:** The risk of unauthorized access, disclosure, or government access is minimal due to the offline, local-only architecture

### 8.2 Compliance Status
**EU Standard Contractual Clauses (SCCs):**
- **Clause 14(b) Compliance:** This assessment addresses all requirements of Clause 14(b)
- **Transfer Mechanism:** While no transfer occurs, this document demonstrates compliance with GDPR transfer requirements
- **Safeguards:** The local-only architecture provides the highest level of data protection

**Note:** If Company engages in any future data transfers (e.g., adding cloud features), this assessment must be updated accordingly.

---

## CERTIFICATION

I hereby certify that the information provided in this Transfer Risk Assessment is accurate to the best of my knowledge, subject to any legal prohibitions on disclosure (including gag orders or national security restrictions).

**Authorized Representative:** ___________________________  
**Name:** ___________________________  
**Title:** ___________________________  
**Date:** ___________________________  
**Signature:** ___________________________

---

## APPENDIX: DEFINITIONS

**Personal Data:** For purposes of Arcadia, personal data includes:
- User preferences (theme, volume, UI settings)
- User-created sound mixes
- Application usage data (if any analytics were added in future)
- Onboarding completion status

**Data Transfer:** For purposes of this assessment, a data transfer means the transmission of personal data from the user's device to Company infrastructure, third-party servers, or any other external recipient.

**Onward Transfer:** Transfer of personal data from Company to a third party or sub-processor.

**Company:** Luziv, the entity that developed and operates the Arcadia application.

---

## UPDATES AND REVISIONS

This Transfer Risk Assessment must be reviewed and updated:
- If Company changes its jurisdiction or incorporation location
- If the application adds any data transmission features
- If Company engages any sub-processors
- If applicable laws change
- Annually or as required by applicable regulations

**Last Updated:** [Date]  
**Next Review Date:** [Date + 1 year]

