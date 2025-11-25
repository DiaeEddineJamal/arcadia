# Onward Transfer Intentions and Safeguards Against Public Authority Access

**Application:** Arcadia (com.Luziv.arcadia)  
**Data Controller:** Luziv  
**Document Version:** 1.0  
**Effective Date:** [Date]

---

## 1. COMPANY'S INTENTION FOR ONWARD TRANSFER

### 1.1 Summary
**Estimated Number of Further Recipients:** ZERO (0)

**Processing Chain Length:** N/A - No processing chain exists

**Onward Transfer Status:** NO ONWARD TRANSFERS OCCUR OR ARE PLANNED

### 1.2 Detailed Onward Transfer Assessment

#### Current State (No Transfers)
- **No Data Transmission:** Personal data never leaves the user's device
- **No Third-Party Recipients:** Company does not transfer data to any third parties, sub-processors, or external services
- **No Processing Chain:** There is no processing chain as all data processing occurs locally on the user's device

#### No Sub-Processors Engaged
Company does not engage any sub-processors for personal data processing:

| Service Type | Provider | Data Processed | Status |
|-------------|----------|----------------|--------|
| Cloud Storage | N/A | None | Not used |
| Analytics | N/A | None | Not used |
| Authentication | N/A | None | Not used |
| Payment Processing | N/A | None | Not used |
| Customer Support | N/A | None | Not used |
| Advertising | N/A | None | Not used |
| Crash Reporting | N/A | None | Not used |

#### Future Intentions
**Policy:** Company commits that any future changes to data processing that would involve onward transfers will:
1. Be clearly disclosed to users in the privacy policy
2. Require appropriate data protection agreements (DPAs/SCCs) where applicable
3. Obtain explicit user consent where required
4. Maintain compliance with GDPR requirements
5. Be documented and updated in this assessment

**No Planned Changes:** Currently, Company has no plans to implement features that would require onward transfers.

---

## 2. SAFEGUARDS AGAINST INTERCEPTION OR DISPROPORTIONATE ACCESS BY PUBLIC AUTHORITIES

This section details the contractual, technical, and organisational measures implemented to safeguard personal data from interception or disproportionate access by public authorities, in addition to the measures described in Annex II of the EU Standard Contractual Clauses.

---

## 2.1 TECHNICAL MEASURES

### 2.1.1 Data Encryption at Rest
**Implementation:**
- **Android Devices:**
  - Application data stored in `/data/data/com.Luziv.arcadia/app_flutter/`
  - Protected by Android's File-Based Encryption (FBE)
  - Data encrypted at the file system level using AES-256 encryption
  - Encryption keys managed by Android Keystore System
  - Encryption is automatic and transparent to the application

- **iOS Devices:**
  - Application data stored in app sandbox
  - Protected by iOS Data Protection API
  - Data encrypted with AES-256 encryption
  - Encryption keys stored in device's Secure Enclave
  - Class-level data protection (NSFileProtectionComplete)

**Protection Against Public Authority Access:**
- Encryption keys are stored in hardware-backed secure storage (Android Keystore/iOS Secure Enclave)
- Keys cannot be extracted even with device administrator access
- File system encryption prevents access to data even if storage is physically accessed
- Encryption is device-specific, making data inaccessible on other devices

### 2.1.2 No Network Transmission
**Implementation:**
- Application operates entirely offline
- No network APIs or endpoints are used
- No data packets are transmitted over networks
- No communication protocols that could be intercepted

**Protection Against Interception:**
- **Zero Interception Risk:** Since no data is transmitted, there is no opportunity for interception during transmission
- **No Network Attack Surface:** Eliminates risk of:
  - Man-in-the-middle attacks
  - Network interception
  - Traffic analysis
  - Deep packet inspection

### 2.1.3 Application Sandbox Isolation
**Implementation:**
- **Android:** Application sandbox enforced by Android security model
  - Each application runs in isolated process
  - File system access restricted to application directory
  - Inter-process communication restricted
  - SELinux policies enforce isolation

- **iOS:** Application sandbox enforced by iOS security model
  - Each application runs in isolated container
  - File system access restricted to app bundle
  - No inter-app communication without explicit permissions
  - Sandboxing enforced at kernel level

**Protection Against Access:**
- Even if device is compromised, sandbox isolation prevents other applications from accessing app data
- Operating system enforces access controls
- Data is not accessible via standard file system browsing

### 2.1.4 Local-Only Storage Architecture
**Implementation:**
- All data stored using Hive local database
- Data never transmitted to external servers
- No cloud backup or synchronization
- No external API calls

**Protection:**
- Data exists only on user's device
- No central repository that could be subject to government access requests
- Company has no ability to access data even if requested
- Data deletion is immediate and permanent

### 2.1.5 Type-Safe Data Models
**Implementation:**
- Strongly-typed data models using Hive Type Adapters
- Schema validation prevents data corruption
- Immutable data patterns where applicable

**Protection:**
- Reduces risk of data leaks through improper data handling
- Type safety prevents accidental data exposure
- Validation ensures data integrity

---

## 2.2 ORGANISATIONAL MEASURES

### 2.2.1 Privacy-by-Design Architecture
**Implementation:**
- Application designed from inception with privacy principles
- No data collection beyond necessary functionality
- Local-only processing as default architecture
- No external dependencies that would require data transmission

**Protection:**
- Minimizes data exposure risk by design
- No unnecessary data processing creates no unnecessary exposure
- Architecture decisions prioritize user privacy

### 2.2.2 Data Minimization Policy
**Implementation:**
- Only collects/store user preferences necessary for app functionality
- No personal identifiers collected (no names, emails, device IDs)
- No behavioral tracking or analytics
- User-created content (sound mixes) stored locally only

**Protection:**
- Minimal data means minimal exposure risk
- No sensitive personal data to protect
- Limited scope of potential government access requests

### 2.2.3 Development and Security Practices
**Implementation:**
- Code review processes for security vulnerabilities
- Regular dependency updates for security patches
- Static code analysis to identify potential issues
- Secure development lifecycle

**Protection:**
- Reduces risk of security vulnerabilities that could be exploited
- Regular updates address newly discovered threats
- Security-focused development reduces attack surface

### 2.2.4 Access Control and Staff Training
**Implementation:**
- Restricted access to source code repository
- Development team trained on privacy principles
- Awareness of GDPR requirements
- No unauthorized access to user data (as none exists on Company infrastructure)

**Protection:**
- Limits risk of internal data access issues
- Trained staff understand privacy obligations
- Clear policies prevent accidental data handling

### 2.2.5 No Third-Party Service Integration
**Implementation:**
- No integration with services that could process user data
- No analytics platforms
- No cloud services
- No external APIs

**Protection:**
- Eliminates risk through third-party services
- No third-party contracts that could involve data access
- No vendor risk assessment needed (no vendors)

### 2.2.6 Incident Response Procedures
**Implementation:**
- Procedures for addressing security incidents
- User notification procedures (if applicable)
- Regular security assessments

**Protection:**
- Prepared response minimizes impact of any potential incidents
- Rapid response capability
- Transparency with users

---

## 2.3 CONTRACTUAL MEASURES

### 2.3.1 Application Store Agreements
**Contractual Safeguards:**
- Compliance with Google Play Store and Apple App Store privacy requirements
- App store policies require transparency about data collection
- App store review processes ensure compliance

**Protection:**
- Contractual obligations with app stores ensure privacy disclosure
- Store policies limit data collection practices
- Store review acts as independent verification

### 2.3.2 Privacy Policy Commitments
**Contractual Safeguards:**
- Public privacy policy commits to local-only storage
- Clear disclosure of data practices
- User-facing commitments to privacy protection

**Protection:**
- Contractual obligation to users (via privacy policy)
- User trust and expectations
- Legal enforceability of privacy commitments

### 2.3.3 Terms of Service Commitments
**Contractual Safeguards:**
- Terms of service specify data handling practices
- Commitments to user privacy
- Limitations on data use

**Protection:**
- Legally binding commitments to users
- User rights enforceable through terms
- Clear contractual framework

### 2.3.4 No Third-Party Contracts (Current)
**Status:** No third-party data processing agreements exist because no third parties process user data.

**Future Contracts (if applicable):**
- Any future sub-processors would require Data Processing Agreements (DPAs)
- Standard Contractual Clauses (SCCs) would be included where transfers occur
- Vendor risk assessments would be conducted
- Regular audits of third-party compliance

---

## 2.4 ADDITIONAL SAFEGUARDS SPECIFIC TO PUBLIC AUTHORITY ACCESS

### 2.4.1 Architecture-Based Protection
**No Company-Accessible Data:**
- Company has no infrastructure where user data is stored
- Company has no ability to access user data even if legally compelled
- No servers, databases, or cloud storage under Company control containing user data
- This architectural limitation provides the strongest protection against government access

**Protection Mechanism:**
Even if public authorities were to request data from Company:
- Company would have no data to provide
- No infrastructure exists that could be subject to search warrants
- No data retention systems that could be compelled to disclose information

### 2.4.2 User Device Protection
**Device-Level Encryption:**
- Modern Android and iOS devices use full-disk encryption
- Data on device is encrypted by default
- Requires device unlock credentials to decrypt
- Protects against physical device seizure

**Operating System Protections:**
- Android/iOS security models protect against unauthorized access
- App sandboxing prevents cross-app data access
- System-level encryption prevents unauthorized data reading

### 2.4.3 Transparency and User Control
**User Rights:**
- Users have full control over their data
- Users can delete all data at any time (uninstall app or clear data)
- No Company access means users maintain complete control
- No hidden data retention

**Protection:**
- Users aware of data practices (transparency)
- Users can remove data independently
- User control reduces risk of prolonged data retention

---

## 2.5 RISK MITIGATION SUMMARY

### 2.5.1 Protection Layers

| Protection Layer | Mechanism | Effectiveness |
|----------------|-----------|--------------|
| **Architecture** | No data transmission, local-only storage | HIGH - Eliminates most risks |
| **Encryption** | Device-level and file system encryption | HIGH - Protects at-rest data |
| **Isolation** | Application sandbox | HIGH - Prevents cross-app access |
| **No Infrastructure** | No Company servers/storage | HIGH - No Company-accessible data |
| **Minimal Data** | Only preferences, no identifiers | MEDIUM - Limited scope if accessed |
| **User Control** | User can delete anytime | MEDIUM - User empowerment |

### 2.5.2 Risk Assessment for Public Authority Access

**Risk Level:** VERY LOW

**Justification:**
1. **No Company Data:** Company has no user data to access
2. **No Infrastructure:** No servers or databases subject to warrants
3. **Local-Only:** All data exists only on user device
4. **Encrypted:** Device and file system encryption protect data
5. **Isolated:** Application sandbox prevents unauthorized access

**Scenarios Where Risk Could Increase:**
- Future addition of cloud features (would require updated safeguards)
- Changes to architecture that involve data transmission
- Engagement of third-party services

**Mitigation:** Any future changes would require:
- Updated privacy policy
- New technical safeguards
- Updated risk assessment
- User notification of changes

---

## 2.6 COMPLIANCE WITH EU STANDARD CONTRACTUAL CLAUSES

### 2.6.1 Additional Safeguards Beyond Annex II
This document supplements Annex II (Technical and Organisational Measures) by specifically addressing:
- Protection against public authority access
- Interception prevention measures
- Onward transfer restrictions
- Contractual commitments

### 2.6.2 SCC Compliance
**Clause 14(b) Compliance:**
- This document addresses onward transfer intentions (Section 1)
- Details safeguards against public authority access (Section 2)
- Provides transparency required by SCCs

**Clause 14(c) Compliance:**
- Demonstrates that technical and organisational measures have been implemented
- Shows ongoing commitment to data protection

---

## 2.7 USER NOTIFICATION AND TRANSPARENCY

### 2.7.1 Privacy Policy Disclosure
**Commitments Made to Users:**
- Application operates entirely offline
- All data stored locally on device
- No data transmission to Company or third parties
- No analytics or tracking

**Protection:**
- Users are informed of privacy practices
- Transparency builds trust
- Users can make informed decisions

### 2.7.2 User Rights
**Rights Provided:**
- Right to access (view settings in app)
- Right to deletion (clear all data in settings)
- Right to data portability (local storage accessible)
- Right to object (can disable features)

**Protection:**
- Users maintain control
- Rights are easily exercisable
- No barriers to exercising rights

---

## 2.8 MONITORING AND REVIEW

### 2.8.1 Regular Assessment
**Review Schedule:**
- Annual review of safeguards
- Review upon architectural changes
- Review if adding third-party services
- Review if changing jurisdiction

### 2.8.2 Update Procedures
**Trigger Events:**
- Addition of cloud features
- Engagement of sub-processors
- Changes to data processing practices
- New regulations or requirements

**Update Requirements:**
- This document must be updated
- Privacy policy must be updated
- Users must be notified
- Risk assessment must be revised

---

## CERTIFICATION

I hereby certify that:
1. Company has no intention to engage in onward transfers of personal data
2. The technical, organisational, and contractual measures described in this document are implemented and maintained
3. These measures provide appropriate safeguards against interception and disproportionate access by public authorities
4. Company is committed to maintaining these safeguards and updating them as necessary

**Authorized Representative:** ___________________________  
**Name:** ___________________________  
**Title:** ___________________________  
**Date:** ___________________________  
**Signature:** ___________________________

---

## APPENDIX: TECHNICAL SPECIFICATIONS

### Encryption Details
- **Android:** AES-256 via Android File-Based Encryption (FBE)
- **iOS:** AES-256 via iOS Data Protection API
- **Key Storage:** Hardware-backed secure storage (Android Keystore / iOS Secure Enclave)

### Storage Locations
- **Android:** `/data/data/com.Luziv.arcadia/app_flutter/`
- **iOS:** Application sandbox (Documents/Library)
- **Format:** Hive binary database (encrypted by OS)

### Network Protocols
- **None:** Application uses no network protocols
- **No APIs:** No external API endpoints
- **No Services:** No cloud services

### Third-Party Dependencies
- **Hive:** Local database (no network access)
- **AudioPlayers:** Audio playback (no network access)
- **All dependencies:** Verified for offline-only operation

