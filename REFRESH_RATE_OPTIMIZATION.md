# Maximum Refresh Rate Configuration

## Overview

The app is now configured to automatically use the maximum available refresh rate on the user's device for the smoothest possible experience.

## Implementation

### Automatic Detection and Application
- **Initial Setup**: On app startup, the system detects all available display modes
- **Highest Rate Selection**: Automatically finds and selects the highest available refresh rate (60Hz, 90Hz, 120Hz, etc.)
- **Verification**: After setting, verifies the active refresh rate matches expectations

### Multi-Platform Support
- **Android**: Uses `flutter_displaymode` plugin to set high refresh rate
- **iOS**: Automatically handles ProMotion displays (120Hz on iPhone 13 Pro and later)
- **Fallback**: Gracefully handles devices that don't support refresh rate changes

### Persistence Across App Lifecycle
- **On Resume**: Re-applies high refresh rate when app returns from background
  - Some devices reset refresh rate when app goes to background
  - Ensures smooth experience is maintained
- **Post-Frame Callback**: Re-verifies refresh rate after first frame render
  - Handles edge cases where initial setting didn't apply

## Supported Refresh Rates

The app will automatically use the maximum available refresh rate:
- **60Hz**: Standard devices
- **90Hz**: Mid-range devices (many Android phones)
- **120Hz**: High-end devices (Galaxy S series, iPhone Pro models, Pixel Pro)
- **144Hz+**: Gaming phones and high-end displays

## Performance Benefits

### Smoothness Improvements
- **120Hz Display**: Up to 2x smoother than 60Hz
- **90Hz Display**: 50% smoother animations and scrolling
- **Reduced Motion Blur**: Especially noticeable during rapid UI changes
- **Better Responsiveness**: Lower input lag for touch interactions

### User Experience
- Buttery-smooth animations
- Ultra-responsive UI interactions
- Reduced visual stuttering
- Professional-grade app feel

## Technical Details

### Implementation Location
- `lib/main.dart`: `_configureHighRefreshRate()` function
- Called during app initialization
- Re-applied on app resume
- Verified after first frame

### Logging
The app logs refresh rate information in debug mode:
- Available refresh rates detected
- Highest refresh rate found
- Active refresh rate after setting
- Warnings if refresh rate couldn't be set to maximum

### Error Handling
- Gracefully handles unsupported platforms (iOS simulator, etc.)
- Fallback to system default if plugin fails
- No crashes if refresh rate API unavailable

## Notes

- Some devices with LTPO displays may dynamically adjust refresh rate based on content
- Battery consumption may be slightly higher with higher refresh rates
- The app respects device capabilities and doesn't force unsupported modes
- Refresh rate setting applies only to the app, not system-wide

## Testing

To verify the refresh rate is working:
1. Run the app on a device with high refresh rate capability
2. Check debug console for refresh rate logs
3. Observe smooth animations and scrolling
4. Use Flutter DevTools Performance tab to verify frame times

## Future Enhancements

Potential improvements:
- User setting to toggle high refresh rate (for battery saving)
- Dynamic refresh rate adjustment based on content type
- Battery-aware refresh rate scaling

