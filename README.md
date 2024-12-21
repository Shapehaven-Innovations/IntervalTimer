# IntervalTimer

IntervalTimer is a simple and customizable interval timer app built with SwiftUI. It allows users to set timers for workouts, tasks, or breaks with configurable work durations, rest durations, and sets.

## Features

- **Customizable Intervals**: 
  - Set work and rest durations.
  - Configure the number of sets.
- **Interactive Timer**:
  - Visual progress indicator using animated circles.
  - Real-time updates with a dynamic display of the current set and activity status (Work/Rest).
- **Sound Alerts**:
  - Audio cues for transitions between work, rest, and activity completion.
- **Responsive Design**:
  - Handles both portrait and landscape orientations seamlessly.
- **Intuitive Interface**:
  - Easy-to-use navigation and controls for starting, pausing, and resetting the timer.

## Requirements

- **iOS 14.0 or later**
- **Xcode 12 or later**

## Installation

1. Clone the repository or download the source code.
   ```bash
   git clone https://github.com/wolfrayet0855/IntervalTimer.git
   ```
2. Open the project in Xcode.
   ```bash
   open IntervalTimer.xcodeproj
   ```
3. Build and run the app on a simulator or physical device.

## Usage

### Main Timer Screen
- Displays the current timer and the set progress.
- Buttons to **Start**, **Pause**, and **Reset** the timer.

### Interval Configuration
- Accessible via the "Interval Configuration" button.
- Allows customization of:
  - Work Duration
  - Rest Duration
  - Number of Sets

### Sounds
- Audio alerts for:
  - Start of work intervals.
  - Start of rest intervals.
  - Activity completion.

## Code Highlights

- **Progress Visualization**: 
  - Animated circular progress bar implemented using `Circle` and `trim`.

- **Audio Playback**:
  - Uses `AVAudioPlayer` to play sound effects for activity transitions.

- **Settings Management**:
  - `@State` and `@Binding` properties enable live updates between views.

- **Orientation Handling**:
  - Detects device orientation changes using `NotificationCenter`.


## Future Enhancements

- Add dark mode support.
- Allow saving multiple interval configurations.
- Enable background mode for timer.
- Add haptic feedback for transitions.


## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
