---
name: flutter-ios-ui-iteration
description: Use when working on a Flutter iOS app and the task requires interacting with app UI elements to verify a user flow, inspecting the rendered UI, comparing the current UI with a target design or reference image, or modifying any visible UI element such as layout, spacing, typography, color, icons, controls, navigation, animations, or responsive behavior. Also use whenever the user comments on the appearance or behavior of a Flutter UI element and the result should be validated in the iOS Simulator.
---

# Flutter iOS UI Iteration

Follow this workflow when developing or validating Flutter UI on iOS. The developer owns the application lifecycle through a separately running `flutter run` session. Never launch or terminate the app through the iOS Simulator MCP.

## Workflow

1. Run `flutter attach` to connect to the currently running app.
2. If attaching fails, stop immediately and inform the user. Do not launch, restart, or terminate the app as a workaround.
3. Keep the Flutter CLI session alive throughout the task.
4. Use the iOS Simulator MCP to inspect the rendered UI, capture screenshots, and interact with UI elements or user flows.
5. Compare the rendered result with the provided reference image or stated requirements.
6. If the reference image conflicts with the specification or the user's instructions, follow the specification or the user's instructions.
7. Modify the Dart code.
8. Apply changes with Flutter hot reload by sending `r` to the attached Flutter session.
9. Inspect and interact with the updated UI in the iOS Simulator.
10. Repeat the inspect, modify, hot reload, and inspect cycle until the result matches the target and the relevant flow is verified.

Use hot restart by sending `R` only when hot reload cannot apply the change. Do not restart the app merely for convenience.

## Tool Responsibilities

- Use the Flutter CLI for attaching, hot reload, hot restart, logs, and application lifecycle control.
- Use the iOS Simulator MCP only for visual inspection, screenshots, and UI interaction.
