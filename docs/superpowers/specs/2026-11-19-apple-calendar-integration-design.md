# Apple Calendar Integration (MVP1) — Design

**Date:** 2026-11-19
**Status:** Approved in conversation; awaiting written-spec review
**Source:** `Documents/project_description.md`, MVP1 Task 3 and the "Add to calendar" user flow

## Goal

A student can put an assignment's due date into Apple Calendar in a couple of taps, so it sits next to
their classes, practices, and shifts — without HomeworkPal ever being able to read their calendar.

## Decisions

| Decision | Choice | Reason |
|---|---|---|
| Permission model | None. Use Apple's system Add Event sheet (`EKEventEditViewController`). | Keeps the promise that HomeworkPal cannot see other events. The sheet runs out of process and needs no calendar access. |
| Dedicated "HomeworkPal" calendar | Deferred to MVP2 | Creating a calendar requires full access, which MVP2 requests for automatic sync. |
| Pre-permission explanation screen | Dropped | There is no permission prompt to explain. |
| "Open in Calendar" confirmation | Dropped | The student has just seen and confirmed the event in Apple's sheet. |
| Entry points | Both: an Add to Calendar switch in New Assignment, and a long-press action on assignment rows | Covers new and existing assignments. |
| Event length | Zero (start = end = due date) | A due date is a moment, not a block of time. |
| Event alert | None set by the app | Warnings come from MVP2's separate reminders. |
| Added status | Shown | Students want to know what is already in their calendar. |

## User Experience

### From New Assignment

1. The form shows an **Add to Calendar** switch below the due date, off by default.
2. With the switch on, tapping **Add** saves the assignment and closes the form.
3. Apple's Add Event sheet then opens, pre-filled. The student may edit anything (including which calendar)
   and taps **Add** to save or **Cancel** to skip.
4. Cancelling never undoes the assignment.

### From an existing assignment

Long-pressing an assignment row in Upcoming or Calendar shows **Add to Calendar**, which opens the same
pre-filled sheet. Once added, the item reads **Add to Calendar Again**.

### Event contents

| Field | Value |
|---|---|
| Title | `<assignment title> (<class name>)`, e.g. "Lab report: Titration (Chemistry)" |
| Start / End | Both equal to the due date (zero-length event) |
| Calendar | The student's default calendar; changeable in the sheet |
| Alert | None added by the app. If the student has a default alert set in iOS Calendar settings, the system sheet may add it, visibly and removably. |
| Notes | "Added by HomeworkPal" |

### Added status

- An assignment is marked added only when the student taps **Add** in Apple's sheet.
- Rows show a small calendar icon for added assignments, with the accessibility label "Added to Calendar".
- Known limits: without calendar access the app cannot detect if the event is later deleted, and the status
  is in memory only until persistence exists.

## Architecture

### New files

- **`Shared/Components/AddToCalendarSheet.swift`** — `UIViewControllerRepresentable` wrapping
  `EKEventEditViewController`. Inputs: an `Assignment` and an `onSaved` closure. A coordinator acts as
  `EKEventEditViewDelegate`, calls `onSaved` only for the `.saved` action, and dismisses in every case.
  The only file that imports EventKitUI.
- **`Shared/Extensions/Assignment+CalendarEvent.swift`** — pure Foundation. Derives the event title,
  start, end, and notes from an assignment so the rules are unit-testable without EventKit UI.

### Changed files

| File | Change |
|---|---|
| `Features/Dashboard/Models/Assignment.swift` | Add `isAddedToCalendar: Bool`, default `false`. |
| `Features/Dashboard/ViewModels/AddAssignmentViewModel.swift` | Add `@Published var addToCalendar = false`. |
| `Features/Dashboard/Views/AddAssignmentView.swift` | Show the switch; `onSave` passes the assignment and the switch value. |
| `Features/Dashboard/ViewModels/DashboardViewModel.swift` | `addAssignment(_:addToCalendar:)` queues the assignment when the switch is on; `presentQueuedCalendarEvent()` moves the queued assignment to `assignmentToAddToCalendar`; `requestCalendarEvent(for:)`; `markAddedToCalendar(_:)`. |
| `Features/Dashboard/Views/DashboardView.swift` | Add sheet's `onDismiss` calls `presentQueuedCalendarEvent()`; `.sheet(item: $viewModel.assignmentToAddToCalendar)` presents `AddToCalendarSheet`; rows get the long-press action; passes `markAddedToCalendar` to `CalendarView`. |
| `Features/Calendar/ViewModels/CalendarViewModel.swift` | `assignmentToAddToCalendar`, `requestCalendarEvent(for:)`, `markAddedToCalendar(_:)`. |
| `Features/Calendar/Views/CalendarView.swift`, `CalendarDayRow.swift` | Present the sheet; rows get the long-press action; new `onAddedToCalendar` callback beside `onComplete`. |
| `Shared/Components/AssignmentRow.swift` | Optional `onAddToCalendar` action that adds the context menu; calendar icon when added. |

### Data flow

- **New Assignment:** form → `onSave(assignment, addToCalendar)` → Dashboard saves it and, if requested,
  queues it → the form finishes dismissing → `onDismiss` presents Apple's sheet for the queued assignment.
  Waiting for dismissal avoids presenting one sheet while another is still closing.
- **Row action:** row → `requestCalendarEvent(for:)` → `assignmentToAddToCalendar` drives `.sheet(item:)`
  → on save, `markAddedToCalendar`.
- **Calendar screen:** `markAddedToCalendar` also calls `onAddedToCalendar`, which Dashboard wires to its own
  `markAddedToCalendar`, keeping both screens in step (same pattern as `onComplete`).

### Not needed

- No `NSCalendars…UsageDescription` Info.plist keys: the system sheet requires no access.
- No `PrivacyInfo.xcprivacy` changes.

## Error Handling

- Save failures are surfaced by Apple's sheet itself; the app only marks an assignment added on a confirmed save.
- Cancel changes nothing.
- `markAddedToCalendar` looks the assignment up by ID and does nothing if it no longer exists.
- Calendars restricted by Screen Time or device management are handled by the system sheet.

## Testing

Swift Testing unit tests (written, run by the developer):

- `Assignment+CalendarEvent`: title includes the class name; start and end equal the due date; notes set.
- `DashboardViewModel`: switch on queues and `presentQueuedCalendarEvent()` presents then clears the queue;
  switch off queues nothing; `requestCalendarEvent(for:)` sets `assignmentToAddToCalendar`;
  `markAddedToCalendar` sets the flag.
- `CalendarViewModel`: request sets `assignmentToAddToCalendar`; `markAddedToCalendar` sets the flag and
  the assignment stays in its day.
- `AddAssignmentViewModel`: `addToCalendar` defaults to `false`.
- `AddToCalendarSheet` is a thin system-UI wrapper: covered by previews (rows with and without the added icon)
  and a manual check of the real sheet.

## Out of Scope (later MVPs)

- Dedicated "HomeworkPal" calendar, automatic sync, updating or removing events on edit or completion (MVP2).
- Reminders and alerts (MVP2).
- Assignment Detail screen with Calendar status.
- Persisting assignments and the added status.
