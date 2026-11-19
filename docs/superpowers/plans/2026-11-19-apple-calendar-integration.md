# Apple Calendar Integration (MVP1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a student send an assignment's due date to Apple Calendar through Apple's system Add Event sheet — from a switch in New Assignment or a long-press action on any row — and show which assignments were added.

**Architecture:** A pure-Foundation extension derives event details from an `Assignment`; a single `UIViewControllerRepresentable` (`AddToCalendarSheet`) wraps `EKEventEditViewController`, which needs no calendar permission. Dashboard and Calendar ViewModels each hold an `assignmentToAddToCalendar: Assignment?` that drives `.sheet(item:)`, and Calendar reports saves back to Dashboard through a callback, like `onComplete`.

**Tech Stack:** Swift 6 (strict concurrency), SwiftUI, EventKit + EventKitUI, Combine `ObservableObject` ViewModels, Swift Testing.

**Spec:** `docs/superpowers/specs/2026-11-19-apple-calendar-integration-design.md`

## Global Constraints

- iOS 27.0 deployment target; follow `Documents/CLAUDE.md` (feature-scoped `ObservableObject` VMs, `@MainActor`, no business logic in views, named constants, `Theme` tokens, every view has `#Preview`).
- **Do not run tests, `xcodebuild test`, or any simulator.** The developer runs tests in Xcode. Verify each task by checking IDE diagnostics for the touched files (VS Code `getDiagnostics`) and re-reading the diff.
- No calendar permission requests, no `NSCalendars…UsageDescription` keys, no `PrivacyInfo.xcprivacy` changes.
- Event: title `"<assignment title> (<class name>)"`, start = end = due date, no alarms added by the app, notes `"Added by HomeworkPal"`. Do not set `event.calendar`: without access the app cannot read calendars, and the system sheet fills in the student's default.
- User-facing strings go through `String(localized:)` / `Text` literals so they land in `Localizable.xcstrings`; never concatenate localized strings.
- Copy: switch label "Add to Calendar"; menu items "Add to Calendar" / "Add to Calendar Again"; added icon accessibility label "Added to Calendar".
- Work on branch `features/apple-calendar-integration`; one commit per task ending with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **Form cancelled with the switch on** — the New Assignment sheet is dismissed via Cancel: nothing is queued and Apple's sheet must not open. (Test in Task 4: `presentQueuedCalendarEventWithNothingQueuedDoesNothing`.)
2. **Assignment completed while Apple's sheet is open** — saving then marks a missing/completed assignment: must not crash or resurrect it. (Tests in Tasks 4 and 5: `markAddedToCalendarIgnoresUnknownAssignment`.)
3. **Adding the same assignment twice** — second save keeps the status true and nothing else changes. (Test in Task 4: `markAddedToCalendarIsIdempotent`.)
4. **Added from the Calendar screen, then closing it** — Upcoming must show the added icon too. Wiring is view-level; manual check listed in Task 5.
5. **Queued assignment presented twice** — `onDismiss` firing again must not reopen Apple's sheet. (Test in Task 4: `presentQueuedCalendarEventClearsQueue`.)

---

### Task 1: Event details and added flag

**Files:**
- Modify: `HomeworkPal/Features/Dashboard/Models/Assignment.swift`
- Create: `HomeworkPal/Shared/Extensions/Assignment+CalendarEvent.swift`
- Test: `HomeworkPalTests/Shared/AssignmentCalendarEventTests.swift`

**Interfaces:**
- Produces: `Assignment.isAddedToCalendar: Bool` (stored `var`, init parameter `isAddedToCalendar: Bool = false`, placed after `isCompleted`).
- Produces: `struct CalendarEventDetails: Equatable, Sendable { let title: String; let startDate: Date; let endDate: Date; let notes: String }` and `extension Assignment { var calendarEventDetails: CalendarEventDetails }`, both in the new file.

- [ ] **Step 1: Write the failing tests** in `AssignmentCalendarEventTests` (`@testable import HomeworkPal`, `import Testing`):
  - `titleIncludesClassName`: `Assignment(title: "Lab report: Titration", course: .chemistry, dueDate: due)` → `#expect(details.title == "Lab report: Titration (Chemistry)")`.
  - `eventIsInstantAtDueDate`: `#expect(details.startDate == due)` and `#expect(details.endDate == due)`.
  - `notesCreditHomeworkPal`: `#expect(details.notes == "Added by HomeworkPal")`.
  - `newAssignmentIsNotAddedToCalendar`: `#expect(!Assignment(title: "A", course: .english, dueDate: .now).isAddedToCalendar)`.
- [ ] **Step 2: Implement** the flag and the extension. Title via `String(localized: "\(title) (\(course.name))")`; notes via `String(localized: "Added by HomeworkPal")`.
- [ ] **Step 3: Verify** — no diagnostics in the three files; existing `Assignment(...)` call sites still compile (the new parameter is defaulted).
- [ ] **Step 4: Commit** — `git commit -m "Add calendar event details and added flag to Assignment"`

### Task 2: AddToCalendarSheet component

**Files:**
- Create: `HomeworkPal/Shared/Components/AddToCalendarSheet.swift`

**Interfaces:**
- Consumes: `Assignment.calendarEventDetails` (Task 1).
- Produces: `struct AddToCalendarSheet: UIViewControllerRepresentable` with `init(assignment: Assignment, onSaved: @escaping () -> Void)`.

- [ ] **Step 1: Implement.**
  - `makeUIViewController` builds an `EKEventEditViewController`, sets `eventStore` to a store held by the coordinator, and an `EKEvent` with `title`, `startDate`, `endDate`, `notes` from `calendarEventDetails`, no `calendar`, and no alarms.
  - `Coordinator: NSObject, EKEventEditViewDelegate` (`@MainActor`). In `eventEditViewController(_:didCompleteWith:)`, call `onSaved()` only when `action == .saved`, then `controller.dismiss(animated: true)`.
  - No usage-description strings are needed; do not request access.
  - `#Preview`: `AddToCalendarSheet(assignment: Assignment.sampleData[0]) {}`.
- [ ] **Step 2: Verify** — no diagnostics; EventKitUI is imported only in this file (`grep -rn "import EventKitUI" HomeworkPal` returns one line).
- [ ] **Step 3: Commit** — `git commit -m "Add AddToCalendarSheet wrapping Apple's event editor"`

### Task 3: Row action and added icon

**Files:**
- Modify: `HomeworkPal/Shared/Components/AssignmentRow.swift`

**Interfaces:**
- Produces: `AssignmentRow.init(assignment:isOverdue:onToggle:onAddToCalendar:)` where `onAddToCalendar: (() -> Void)? = nil` comes **after** the trailing `onToggle` closure is declared, so existing trailing-closure call sites keep compiling. Declare stored property `var onAddToCalendar: (() -> Void)? = nil` after `onToggle`.

- [ ] **Step 1: Implement.**
  - When `onAddToCalendar` is non-nil, attach `.contextMenu` with one `Button` whose label is `Label("Add to Calendar", systemImage: "calendar.badge.plus")`, or `"Add to Calendar Again"` when `assignment.isAddedToCalendar`.
  - When `assignment.isAddedToCalendar`, show `Image(systemName: "calendar")` beside the course label in `Theme.secondaryText`, with `.accessibilityLabel(Text("Added to Calendar"))`.
- [ ] **Step 2: Extend `#Preview`** with a third row: `Assignment(..., isAddedToCalendar: true)` and a non-nil `onAddToCalendar`.
- [ ] **Step 3: Verify** — no diagnostics in `AssignmentRow.swift`, `DashboardView.swift`, `CalendarDayRow.swift` (unchanged call sites still compile).
- [ ] **Step 4: Commit** — `git commit -m "Add Add to Calendar row action and added icon"`

### Task 4: New Assignment switch and Dashboard wiring

**Files:**
- Modify: `HomeworkPal/Features/Dashboard/ViewModels/AddAssignmentViewModel.swift`
- Modify: `HomeworkPal/Features/Dashboard/Views/AddAssignmentView.swift`
- Modify: `HomeworkPal/Features/Dashboard/ViewModels/DashboardViewModel.swift`
- Modify: `HomeworkPal/Features/Dashboard/Views/DashboardView.swift`
- Test: `HomeworkPalTests/Features/Dashboard/AddAssignmentViewModelTests.swift`, `HomeworkPalTests/Features/Dashboard/DashboardViewModelTests.swift`

**Interfaces:**
- Consumes: `AddToCalendarSheet` (Task 2), `AssignmentRow.onAddToCalendar` (Task 3), `isAddedToCalendar` (Task 1).
- Produces on `AddAssignmentViewModel`: `@Published var addToCalendar = false`.
- Produces on `AddAssignmentView`: `onSave: (Assignment, Bool) -> Void` (second argument = switch value).
- Produces on `DashboardViewModel`:
  - `@Published var assignmentToAddToCalendar: Assignment?`
  - `func addAssignment(_ assignment: Assignment, addToCalendar: Bool)` (replaces `addAssignment(_:)`)
  - `func presentQueuedCalendarEvent()` — moves a private queued assignment into `assignmentToAddToCalendar`, then clears the queue
  - `func requestCalendarEvent(for assignment: Assignment)`
  - `func markAddedToCalendar(_ assignment: Assignment)` — looks up by `id`; no-op if absent

- [ ] **Step 1: Write the failing tests.**
  - `AddAssignmentViewModelTests.addToCalendarIsOffByDefault`: `#expect(!viewModel.addToCalendar)`.
  - `DashboardViewModelTests` (update `addAssignmentAppearsInSections` to call `addAssignment(laterAssignment, addToCalendar: false)`), plus:
    - `addingWithCalendarQueuesUntilFormDismisses`: `addAssignment(a, addToCalendar: true)` → `#expect(assignmentToAddToCalendar == nil)`; then `presentQueuedCalendarEvent()` → `#expect(assignmentToAddToCalendar == a)`.
    - `addingWithoutCalendarQueuesNothing`: `addAssignment(a, addToCalendar: false)`; `presentQueuedCalendarEvent()` → `#expect(assignmentToAddToCalendar == nil)`.
    - `presentQueuedCalendarEventWithNothingQueuedDoesNothing`: fresh VM; `presentQueuedCalendarEvent()` → nil.
    - `presentQueuedCalendarEventClearsQueue`: queue `a`, present, set `assignmentToAddToCalendar = nil`, present again → nil.
    - `requestCalendarEventSetsAssignment`: `#expect(assignmentToAddToCalendar == overdueAssignment)`.
    - `markAddedToCalendarSetsFlag`: `#expect(viewModel.assignments.first?.isAddedToCalendar == true)`.
    - `markAddedToCalendarIsIdempotent`: call twice → flag true, `assignments.count` unchanged.
    - `markAddedToCalendarIgnoresUnknownAssignment`: VM with `[overdueAssignment]`; mark `laterAssignment` → `#expect(viewModel.assignments == [overdueAssignment])`.
- [ ] **Step 2: Implement the ViewModels.**
- [ ] **Step 3: Implement the views.**
  - `AddAssignmentView`: `Toggle("Add to Calendar", isOn: $viewModel.addToCalendar)` in `detailsSection` below the `DatePicker`; `save()` calls `onSave(assignment, viewModel.addToCalendar)`. Update both previews to `{ _, _ in }`.
  - `DashboardView`:
    - `.sheet(isPresented: $viewModel.isAddingAssignment, onDismiss: viewModel.presentQueuedCalendarEvent)` and `onSave: viewModel.addAssignment`.
    - Add `.sheet(item: $viewModel.assignmentToAddToCalendar) { assignment in AddToCalendarSheet(assignment: assignment) { viewModel.markAddedToCalendar(assignment) } }`.
    - Pass `onAddToCalendar: { viewModel.requestCalendarEvent(for: assignment) }` to `AssignmentRow`.
- [ ] **Step 4: Verify** — no diagnostics in the four source files and two test files.
- [ ] **Step 5: Commit** — `git commit -m "Add to Calendar from New Assignment and Upcoming rows"`

### Task 5: Calendar screen wiring

**Files:**
- Modify: `HomeworkPal/Features/Calendar/ViewModels/CalendarViewModel.swift`
- Modify: `HomeworkPal/Features/Calendar/Views/CalendarView.swift`
- Modify: `HomeworkPal/Features/Calendar/Views/CalendarDayRow.swift`
- Modify: `HomeworkPal/Features/Dashboard/Views/DashboardView.swift` (the `fullScreenCover` call only)
- Test: `HomeworkPalTests/Features/Calendar/CalendarViewModelTests.swift`

**Interfaces:**
- Consumes: Tasks 1–3; `DashboardViewModel.markAddedToCalendar(_:)` (Task 4).
- Produces on `CalendarViewModel`: `@Published var assignmentToAddToCalendar: Assignment?`, `func requestCalendarEvent(for assignment: Assignment)`, `func markAddedToCalendar(_ assignment: Assignment)` (same semantics as Dashboard's).
- Produces on `CalendarView`: `init(assignments: [Assignment] = Assignment.sampleData, onComplete: @escaping (Assignment) -> Void = { _ in }, onAddedToCalendar: @escaping (Assignment) -> Void = { _ in })`.

- [ ] **Step 1: Write the failing tests** (use the existing `makeViewModel` / `date(day:hour:)` helpers):
  - `requestCalendarEventSetsAssignment`.
  - `markAddedToCalendarSetsFlagAndKeepsDay`: assignment due Nov 19 → after marking, the Nov 19 day's `assignments.first?.isAddedToCalendar == true`.
  - `markAddedToCalendarIgnoresUnknownAssignment`: `days.flatMap(\.assignments)` unchanged.
- [ ] **Step 2: Implement `CalendarViewModel`.**
- [ ] **Step 3: Implement the views.**
  - `CalendarView`: store `onAddedToCalendar`; add `.sheet(item: $viewModel.assignmentToAddToCalendar)` presenting `AddToCalendarSheet` whose `onSaved` calls `viewModel.markAddedToCalendar(assignment)` then `onAddedToCalendar(assignment)`.
  - `CalendarDayRow`: pass `onAddToCalendar: { viewModel.requestCalendarEvent(for: assignment) }`.
  - `DashboardView`: `CalendarView(assignments: viewModel.assignments, onComplete: viewModel.markComplete, onAddedToCalendar: viewModel.markAddedToCalendar)`.
- [ ] **Step 4: Verify** — no diagnostics in the touched files. List for the developer's manual check: add from a Calendar row → close Calendar → the Upcoming row shows the calendar icon (Review Focus 4).
- [ ] **Step 5: Commit** — `git commit -m "Add to Calendar from the Calendar screen"`

### Final handoff to the developer

Tests to run in Xcode (build the app target first because of the missing test-target dependency): `AssignmentCalendarEventTests`, `AddAssignmentViewModelTests`, `DashboardViewModelTests`, `CalendarViewModelTests`. Manual checks: switch on → Add → Apple's sheet opens pre-filled with a zero-length event; Cancel in Apple's sheet leaves no icon; Save shows the icon and the menu reads "Add to Calendar Again".
