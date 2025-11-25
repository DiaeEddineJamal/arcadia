# Annex II: Technical and Organisational Measures Including Technical and Organisational Measures to Ensure the Security of the Data

**Application:** Arcadia (com.Luziv.arcadia)  
**Data Controller:** Luziv  
**Document Version:** 1.0  
**Effective Date:** [Date]

---

## 1. PSEUDONYMISATION AND ENCRYPTION OF PERSONAL DATA

### 1.1 Data Storage Encryption
- **Local Database Encryption**: All data stored locally using Hive database is stored in the device's secure storage area, protected by the operating system's native encryption mechanisms (Android Keystore System / iOS Keychain)
- **At-Rest Protection**: All stored data (app settings, user-created sound mixes, preferences) are stored in encrypted Hive boxes located in the device's application sandbox
- **File System Protection**: Android uses file-based encryption (FBE) and iOS uses Data Protection API to encrypt app data at rest

### 1.2 Data Transmission
- **No Network Transmission**: The application operates entirely offline and does not transmit any personal data over networks
- **No Cloud Storage**: All data remains on the user's device and is never transmitted to external servers or cloud services

---

## 2. ENSURING ONGOING CONFIDENTIALITY, INTEGRITY, AVAILABILITY AND RESILIENCE OF PROCESSING SYSTEMS AND SERVICES

### 2.1 Data Storage Architecture
- **Local-Only Storage**: 
  - Data is stored exclusively on the user's device using Hive local database
  - Storage locations:
    - Android: `/data/data/com.Luziv.arcadia/app_flutter/`
    - iOS: Application sandbox (Documents or Library directory)
  - No external storage or cloud synchronization

### 2.2 Data Access Controls
- **Application Sandbox**: All data is contained within the application's sandbox, accessible only by the application itself
- **Operating System Permissions**: Data access is restricted by Android/iOS security model
- **No Inter-Application Data Sharing**: Data cannot be accessed by other applications

### 2.3 Data Integrity
- **Type-Safe Storage**: Data is stored using strongly-typed Hive adapters with schema validation
- **Immutable Data Models**: Core data models use immutable patterns to prevent accidental modification
- **Validation**: Input validation ensures data integrity before storage

### 2.4 Availability and Resilience
- **Error Handling**: Comprehensive error handling prevents data corruption
- **Graceful Degradation**: Default values are provided if stored data is unavailable
- **Data Recovery**: Initialization routines restore default settings if data corruption is detected

---

## 3. ABILITY TO RESTORE THE AVAILABILITY AND ACCESS TO PERSONAL DATA IN A TIMELY MANNER IN THE EVENT OF A PHYSICAL OR TECHNICAL INCIDENT

### 3.1 Data Backup and Recovery
- **Local Backup**: Users can clear all data and restore to default settings through the app's settings screen
- **Default Settings Restoration**: Application automatically restores default configurations if data corruption is detected
- **Initialization Fallback**: Application initializes with safe defaults if storage initialization fails

### 3.2 Incident Response
- **Error Logging**: Application logs errors to aid in troubleshooting without transmitting data externally
- **Graceful Failure**: Application continues to function with default settings if user data is unavailable

---

## 4. PROCESS FOR REGULAR TESTING, ASSESSING AND EVALUATING THE EFFECTIVENESS OF TECHNICAL AND ORGANISATIONAL MEASURES

### 4.1 Security Testing
- **Code Review**: Regular code reviews to identify potential security vulnerabilities
- **Dependency Updates**: Regular updates of Flutter framework and dependencies to address security patches
- **Platform Updates**: Compatibility with latest Android/iOS security features

### 4.2 Data Protection Assessment
- **Privacy-by-Design**: Application designed with privacy principles - no data collection beyond necessary app functionality
- **Minimal Data Collection**: Only stores user preferences and user-created content locally
- **No Tracking**: Application does not include analytics, tracking, or user behavior monitoring

---

## 5. PSEUDONYMISATION

### 5.1 Data Minimization
- **No Personal Identifiers**: Application does not collect, store, or process personal identifiers (names, email addresses, device IDs, etc.)
- **Preference Data Only**: Only stores non-identifying user preferences:
  - Theme preferences (dark/light mode)
  - Volume settings
  - UI preferences (accent colors, overlay settings)
  - Onboarding completion status

### 5.2 User-Created Content
- **Sound Mixes**: User-created sound mixes are stored with generated UUIDs, not personal identifiers
- **Local Storage Only**: All mixes remain on device and are not transmitted

---

## 6. ORGANISATIONAL MEASURES

### 6.1 Access Control
- **Development Access**: Code access restricted to authorized developers only
- **Repository Security**: Source code stored in private GitHub repository with access controls
- **No Third-Party Data Processors**: No data is shared with third-party services or processors

### 6.2 Data Processing Limitation
- **Purpose Limitation**: Data is processed solely for app functionality (storing user preferences and mixes)
- **Storage Limitation**: Data is retained only as long as the application is installed on the user's device
- **User Control**: Users can delete all app data at any time through device settings or app settings

### 6.3 Staff Training and Awareness
- **Privacy Training**: Development team trained on privacy-by-design principles
- **GDPR Compliance**: Awareness of GDPR requirements and data protection obligations

---

## 7. TECHNICAL SECURITY MEASURES

### 7.1 Application Security
- **Secure Code Practices**:
  - No hardcoded secrets or credentials
  - Input validation on all user inputs
  - Type-safe data models
  - Error handling without exposing sensitive information

### 7.2 Platform Security Features Utilized
- **Android**:
  - Application sandbox isolation
  - File-Based Encryption (FBE)
  - Android Keystore System (if needed for future features)
  - Permission system for audio playback and notifications
  
- **iOS**:
  - Application sandbox isolation
  - Data Protection API
  - Keychain Services (if needed)
  - Permission system for audio playback and notifications

### 7.3 Network Security
- **No Network Connectivity**: Application operates entirely offline, eliminating network-based attack vectors
- **No External APIs**: No communication with external servers or APIs
- **No Data Transmission**: Zero data transmission reduces security exposure

---

## 8. DATA BREACH PREVENTION AND RESPONSE

### 8.1 Prevention Measures
- **Local Storage Only**: No data leaves the device, eliminating transmission-based breaches
- **No External Sharing**: No data sharing with third parties or cloud services
- **Regular Updates**: Application updates include security patches and improvements

### 8.2 Incident Response Plan
- **Detection**: Users can report issues through app store feedback
- **Assessment**: Any reported data issues will be assessed immediately
- **Mitigation**: App updates can be deployed to address security issues
- **Notification**: Users will be notified through app updates if any security issue is identified

---

## 9. DATA SUBJECT RIGHTS

### 9.1 Right to Access
- **User Settings Screen**: Users can view all their stored preferences through the app settings
- **Export Functionality**: Users can view all data stored (implementation available for future version)

### 9.2 Right to Erasure
- **Clear All Data**: Users can delete all app data through Settings → Clear All Data
- **Uninstall**: Uninstalling the application removes all stored data
- **Device Settings**: Users can clear app data through device settings

### 9.3 Right to Data Portability
- **Local Storage**: All data is stored in standard formats (Hive database) accessible to the user
- **Future Export**: Planned feature to export user mixes in JSON format

---

## 10. DATA PROCESSING RECORDS

### 10.1 Data Categories Processed
1. **App Settings** (Non-personal preferences):
   - Theme preference (dark/light)
   - Master volume level
   - Background playback preference
   - Notification preferences
   - Sleep timer default duration
   - Fade in/out settings
   - UI customization (accent colors, overlays)
   - Onboarding completion status

2. **User-Created Content**:
   - Sound mix configurations
   - Mix names and descriptions
   - Favorite mix flags
   - Mix creation timestamps

### 10.2 Data Storage Details
- **Storage Technology**: Hive (NoSQL database for Flutter)
- **Storage Location**: Device application sandbox
- **Data Format**: Binary (Hive format) with type-safe adapters
- **Retention Period**: Until user deletes app or clears data
- **Access**: Application-only, no external access

### 10.3 Legal Basis for Processing
- **Consent**: Implicit through app usage (user configures preferences)
- **Legitimate Interest**: Storing user preferences is necessary for app functionality
- **Contract Performance**: Processing is necessary to provide the app service as requested by the user

---

## 11. ADDITIONAL SECURITY MEASURES

### 11.1 Code Security
- **Dependency Management**: Regular updates to address security vulnerabilities in dependencies
- **Static Analysis**: Code analysis tools to identify potential security issues
- **Secure Development Practices**: Following Flutter security best practices

### 11.2 Build Security
- **Signed Applications**: Release builds are code-signed for platform integrity
- **Obfuscation**: Release builds use code obfuscation (when applicable)
- **No Debug Information**: Release builds exclude debug information

### 11.3 User Permissions
- **Minimal Permissions**: Application only requests necessary permissions:
  - Audio playback permissions (for background audio)
  - Notification permissions (for sleep timer notifications)
  - No location, contacts, or other sensitive permissions

---

## 12. COMPLIANCE AND MONITORING

### 12.1 Compliance Framework
- **GDPR Compliance**: Measures designed to comply with GDPR Article 32 requirements
- **Privacy by Design**: Application designed with privacy principles from the start
- **Data Minimization**: Only necessary data is processed

### 12.2 Monitoring
- **No Tracking**: Application does not monitor user behavior
- **No Analytics**: No third-party analytics or crash reporting that transmits personal data
- **Local Logging Only**: Any logging remains on device and is not transmitted

---

## CERTIFICATION

I hereby certify that the technical and organisational measures described in this Annex II are implemented and maintained for the Arcadia application (com.Luziv.arcadia).

**Data Controller:** Luziv  
**Signature:** ___________________________  
**Date:** ___________________________

---

## APPENDIX: TECHNICAL DETAILS

### Storage Implementation
- **Technology**: Hive Flutter (https://docs.hivedb.dev/)
- **Encryption**: Platform-native encryption (Android FBE, iOS Data Protection)
- **Location**: 
  - Android: `/data/data/com.Luziv.arcadia/app_flutter/`
  - iOS: Application Documents/Library directory

### Data Models
- **Sound**: Sound library entries (no user data)
- **SoundMix**: User-created mixes (contains sound IDs and volume settings)
- **AppSettings**: User preferences (theme, volume, UI settings)

### Permissions Requested
- `FOREGROUND_SERVICE` - For background audio playback
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK` - For audio service
- `POST_NOTIFICATIONS` - For sleep timer notifications
- `SCHEDULE_EXACT_ALARM` - For precise sleep timer
- `WAKE_LOCK` - To maintain audio playback

No permissions requested for:
- Location data
- Contact information
- Device identifiers
- Network access (no internet permission)
- External storage (except for audio caching in temp directory)

