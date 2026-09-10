# simple_intent_receiver

A new Flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Intent Delivery

`IntentReceiver.events` has one consumer by contract. WebLibre uses `IntentBus`
to fan out events to sharing and account handlers. Startup retains at most the
newest 16 launches; after the first subscription ends, launches received without
a subscriber are not replayed to its replacement.

The startup drain times out after five seconds so live delivery cannot remain
blocked forever. Its error is retained for a late listener; a reply received
after the timeout is ignored. Disposal unregisters the Dart handler immediately
and waits at most five seconds for the native release reply.

On Android, the undelivered backlog survives engine replacement within the
process, with readiness kept per plugin. This assumes WebLibre's single-engine
coordinator; it does not persist deliveries across process death.

## Tests

From the repository root, run both halves of the intent delivery tests:

```bash
melos run test-intents --no-select
melos run test-android --no-select
```

The Android task requires a configured Android project and Java 17 for its
Robolectric tests. Run a Flutter Android build first on a clean checkout.
