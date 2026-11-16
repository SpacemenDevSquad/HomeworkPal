# HomeworkPal: Private Homework & Activity Planner for Apple Devices

## 1. Introduction

The main idea of the **HomeworkPal** project is to develop a free, open-source
iOS application that helps high school and college students keep track of
homework, project due dates, and extracurricular commitments in one clean,
simple checklist that works with their Apple Calendar. The target users are
high school and college students who juggle assignments from several classes
alongside clubs, sports, rehearsals, jobs, and other activities, and who
currently rely on memory, scattered notes, paper planners, or general-purpose
to-do apps.

Unlike many student planners, HomeworkPal is built around three commitments:
it is **free with no ads or paywalls**, it is **private by default** (no
account, no tracking, data stays on the device with an optional iCloud
backup), and it is **designed specifically for Apple devices**, so it fits
naturally with the calendar, notifications, and iCloud the student already
uses.

The application is organized around a single question a student asks every
day: *"What do I have due, and when?"* Opening the app shows an **Upcoming**
list that groups work into clear time buckets:

-   **Overdue** --- Items past their due date that are not yet checked off.
-   **Today** --- Items due today.
-   **Tomorrow** --- Items due tomorrow, the most common "don't forget"
    window.
-   **This Week** --- Items due in the next seven days.
-   **Later** --- Everything further out, such as long-term projects.

Each item belongs to a **class** (for homework) or, in a later version, an
**activity** (for extracurriculars). Classes carry a name and a color label so
students can tell at a glance which course an item belongs to. Each item has
a title, a type (homework, project, quiz, test, paper, or other), a due date
and optional time, and optional notes.

Adding an item is designed to take seconds. The student taps a single **+**
button, types a title, picks a class, and chooses a due date from a short set
of quick options (Tomorrow, Next class, In a week) or a date picker. Checking
an item off moves it out of the active list but keeps it in a **Completed**
view, so finished work is never simply lost.

A central feature of the application is its **Apple Calendar integration**.
With one tap, a student can add any due date to their Apple Calendar, in a
dedicated "HomeworkPal" calendar they can show or hide. In a later version,
students can choose to send every due date to their calendar automatically,
and the calendar stays up to date when an assignment is edited, completed, or
deleted. This lets students see homework next to classes, practices, shifts,
and social plans, in the calendar app they already check.

HomeworkPal also sends **local reminder notifications** before due dates,
such as the evening before or a custom time, so students are warned while
there is still time to act.

All data is stored on the device. Students do not create an account, and
HomeworkPal does not collect, sell, or share their data. Students who use
several Apple devices, or who want protection against losing their phone, can
turn on **iCloud sync and backup**, which stores data in the student's own
private iCloud space rather than on HomeworkPal's servers. Because the app is
open source, anyone can check that these privacy claims are true.

------------------------------------------------------------------------

## 2. Significance

Keeping track of due dates is one of the most basic, and most commonly
failed, parts of being a student. High school students may have six or more
classes, each with its own assignments, quizzes, and long-term projects.
College students face a different version of the same problem: fewer class
meetings, longer gaps between deadlines, and syllabi spread across several
learning-management systems. Both groups often add extracurricular
commitments on top of their coursework.

When this information lives in memory, on paper, or across several apps,
students miss deadlines not because they cannot do the work but because they
lose track of it. A missed or late assignment costs grades and adds stress
that could easily have been avoided.

HomeworkPal aims to address this problem in several ways.

First, it provides a **single, simple place for due dates**. Instead of
juggling a paper planner, a notes app, and a general to-do list, students see
every upcoming deadline in one list ordered by urgency. The app does one job
and does it with as little friction as possible.

Second, it **connects homework to the student's real schedule**. A due date
by itself does not show whether the student has time to do the work. Placing
due dates in Apple Calendar, next to classes, practices, and work shifts,
helps students see busy days in advance and plan around them.

Third, it **reaches the student before the deadline**. Timely local
notifications turn a passive list into an active reminder, especially for the
"due tomorrow" window in which most last-minute problems appear.

Fourth, it treats **extracurriculars as part of a student's week**. Students
do not experience homework and activities separately; a Tuesday with a lab
report due and a three-hour rehearsal is a hard Tuesday. Showing both
together gives a more honest picture of the student's workload.

Fifth, it **respects student privacy**. Many students are minors, and many
free planners are supported by advertising, require an account to unlock
sync or reminders, or collect usage data. A planner that works without an
account, shows no ads, and keeps data on the device or in the student's own
iCloud removes a real concern for students and their parents.

Finally, it is **free with nothing held back**. The core features students
need, including calendar integration, reminders, and sync, are not locked
behind a subscription. Students who cannot or will not pay still get the
complete experience.

Market evidence supports the demand. The homework-planner category on the App
Store is crowded and long-lived. The three competitors reviewed in Section 4
have been available since 2009, 2016, and 2018, and together show thousands of
ratings. Their reviews repeatedly ask for features this project targets: sync
between devices, widgets, recurring items, and a way to keep completed work
visible.

The overall goal is to give students a planner they can trust: one that is
quick to use every day, connects to the tools they already rely on, and asks
nothing of them in return.

------------------------------------------------------------------------

## 3. Innovation

The proposed application combines several complementary design choices to
differentiate itself from existing homework planners. Each core innovation
below is described in terms of what current apps do, the gap that remains,
what HomeworkPal does differently, and why it matters to students.

### 3.1 Apple Calendar Integration Included for Free

**What current apps do:** Egenda and Homework Pal keep assignments inside
their own apps; their store listings and reviews do not describe sending due
dates to the system calendar. myHomework offers calendar features, but
third-party reporting describes external calendar access as part of its paid
Premium tier.

**The gap:** Students who live in Apple Calendar must either check a second
app every day or retype due dates by hand.

**What HomeworkPal does differently:** Any assignment can be added to Apple
Calendar with one tap, into a dedicated "HomeworkPal" calendar the student
can color, show, or hide. In a later version, a single setting sends every
due date to the calendar automatically and keeps those events current when
assignments are changed, completed, or deleted. In its first version,
HomeworkPal asks only for permission to *add* events, never to read the
student's existing calendar.

**Why it matters:** Homework appears where students already plan their lives,
next to classes, practices, and shifts. It is the clearest difference a
student will notice in the first few minutes of use, and it costs nothing.

### 3.2 Private by Design: No Account, No Ads, No Tracking

**What current apps do:** myHomework is supported by ads in its free version
and uses an optional account (with Facebook or Google sign-in) to unlock sync
and reminders. Egenda and Homework Pal are free, but neither offers
account-free sync, and some storefront listings show that privacy details
have not been provided.

**The gap:** Students, and parents of younger students, have no planner that
is simultaneously free, ad-free, account-free, and able to sync.

**What HomeworkPal does differently:** The app works fully the moment it is
opened, with no sign-up screen. Data is stored on the device. When the
student turns on iCloud sync, data is stored in the student's own private
iCloud space, not on servers run by HomeworkPal. There are no ads, no
analytics that identify the user, and no third-party sign-in. A **Privacy**
screen explains in plain language where data lives and lets the student
export or delete everything.

**Why it matters:** The student trusts the app because there is nothing to
trust it *with*. Competitors that earn money from ads or accounts cannot
easily copy this without changing their business model.

### 3.3 Homework and Extracurriculars in One Week

**What current apps do:** All three competitors organize items by class.
None presents extracurricular activities (practices, rehearsals, club
meetings, jobs) as a first-class part of the student's week.

**The gap:** Students' busiest days are often caused by the combination of a
deadline and an activity, and no homework app shows that combination.

**What HomeworkPal does differently:** In addition to classes, students can
create **activities** with their own color and repeating schedule (for
example, "Soccer practice, Mon/Wed/Fri 4--6 PM"). Activity events can carry
their own to-dos, such as "Bring permission form." A **Week** view shows
homework due dates and activity times together so the student can spot
crowded days in advance.

**Why it matters:** The app reflects how students actually experience their
schedule, and it directly answers the problem in the idea draft: losing track
of *both* homework and extracurriculars.

### 3.4 Open Source and Built Only for Apple

**What current apps do:** myHomework and Egenda are cross-platform products.
Homework Pal is Apple-only but small in scope. None of the three is presented
as open source.

**The gap:** Cross-platform apps tend to look and behave the same on every
system and may not use Apple features fully. Closed-source apps ask users to
take privacy claims on faith.

**What HomeworkPal does differently:** HomeworkPal is designed only for
iPhone, iPad, and Mac, using standard Apple controls, Dynamic Type, Dark
Mode, VoiceOver, and system features such as notifications and, in later
versions, widgets. The source code is published so anyone can verify how the
app handles data or contribute improvements.

**Why it matters:** Being open source is not, on its own, a feature most
students will notice. Its value is that it makes the privacy promise in 3.2
checkable, and it gives the project a path to community contributions.
Apple-native design shows up as an app that feels familiar and fast from the
first launch.

### 3.5 Clean, Fast, Modern Interface

The idea draft emphasizes a clean, easy-to-use modern UI. Most competitors
also describe themselves as simple and beautiful, so a clean interface is
treated as **table stakes**, not a core innovation. HomeworkPal meets it by
keeping the add-assignment flow under ten seconds, showing urgency through
the time-bucket layout instead of extra screens, and avoiding ads, upsell
banners, and paid themes.

The primary innovation of HomeworkPal is therefore not any single feature,
but the combination of **calendar integration, account-free privacy,
homework and activities in one view, and an open-source, Apple-native
design**, all offered free and without paywalls.

------------------------------------------------------------------------

## 4. Competitive Landscape

The idea draft lists three competing apps by App Store link. Sensor Tower
analysis pages were not provided, and the App Store pages could not be
opened directly from this environment. The information below comes from App
Store listing text visible in search results and from third-party
app-analytics and review sites. Figures marked "estimate" are third-party
estimates, not official data.

### 4.1 Comparison Table

| App | Target users | Key services | Monetization | Key market signals | Main strengths | Main weaknesses |
|---|---|---|---|---|---|---|
| [Egenda -- Homework Manager](https://apps.apple.com/us/app/egenda-homework-manager/id1142359153) | Middle school, high school, and college students | Classes; homework, project, quiz, and test tracking; daily "due tomorrow" reminders; notes; sort by class, due date, completion | Free; listing on Android states no in-app purchases or subscriptions | 4.7 average from about 2,968 ratings; last updated Nov 23, 2024 (AppFollow); listed as #1 "Editor's Choice" in AppsHunter's homework category (updated June 2026) | Simple three-step setup; well-reviewed design; free; accessibility support (speech-to-text, screen reader) | Reviews ask for recurring assignments, archiving old assignments, a reminder to *add* homework, and sync between devices; one review says completed items "disappear" |
| [Homework Pal](https://apps.apple.com/us/app/homework-pal/id1340538392) | Students (secondary school and up) | Overview of upcoming due dates; courses and assignments; color-coded courses; overdue indicator; assignment details | Free | 1.5K ratings, 4.74★ average; ~72.8K installs and ~4.3K monthly active users (AppGoblin estimates); updated Oct 11, 2025; released Jan 2018 | Very simple ("Keep It Simple."); clear overdue and due-tomorrow view; Apple-only | Small feature set; reviews request widgets; privacy details not provided on several storefronts; **name is nearly identical to "HomeworkPal"** |
| [myHomework Student Planner](https://apps.apple.com/us/app/myhomework-student-planner/id303490844) | Middle school, high school, and college students; also schools via Teachers.io | Classes; homework, tests, assignments; calendar view; time, block, and period schedules; reminders; cross-platform sync with account; Teachers.io class import; widgets and file attachments (Premium) | Free with ads; Premium listed at $4.99 (US App Store in-app purchase; described as yearly by third parties); paid themes at $0.99 | iOS: 4.3K ratings, 4.53★ average, released Jan 2009 (AppGoblin). Android: 29.9K ratings, 2.42★ average, revenue 100% ads (AppGoblin estimate) | Most complete feature set; works on iOS, Android, Mac, Windows, and web; offline use; teacher integration | Ads in free version; account required for sync and reminders; external calendar access, widgets, and attachments behind Premium; Android rating is poor; reviews request widgets |

### 4.2 Key Services Sorted

**Table stakes** (offered by nearly all competitors and expected by users):

-   Add assignments with a class, type, and due date
-   Create classes, usually with a color
-   Upcoming or due-soon list, with overdue items highlighted
-   Mark assignments as complete
-   Due-date reminders or notifications
-   Free core app

**Competitor differentiators** (offered by one or a few competitors):

-   Cross-platform sync and website access (myHomework, with account)
-   Teacher-published assignments via Teachers.io (myHomework)
-   Block and period-based class schedules (myHomework)
-   File attachments, themes, and widgets (myHomework, paid)
-   Accessibility features such as speech-to-text input (Egenda)

**Gaps** (needs users raise that no competitor serves well):

-   Sync between devices without creating an account or paying
-   Widgets for checking due dates at a glance, without a paywall
-   Recurring items (weekly problem sets, regular practices)
-   Keeping completed work visible instead of having it disappear
-   Extracurricular activities alongside homework
-   Due dates in the system calendar without a subscription
-   Clear, verifiable privacy for a young audience

### 4.3 Feature Matrix

| Service / innovation | Egenda | Homework Pal | myHomework | **HomeworkPal** |
|---|---|---|---|---|
| Add assignments with class and due date | ✓ | ✓ | ✓ | ✓ |
| Color-coded classes | partial | ✓ | ✓ | ✓ |
| Due-soon / overdue overview | ✓ | ✓ | ✓ | ✓ |
| Due-date reminders | ✓ | ✗ (not listed) | partial (account required) | ✓ |
| Completed items kept and viewable | partial | ✓ | ✓ | ✓ |
| **Add due dates to Apple Calendar** | ✗ | ✗ | partial (Premium) | **✓ free** |
| **Works fully with no account** | ✓ | ✓ | partial (no sync or reminders) | **✓** |
| **Sync across devices without an account** | ✗ | ✗ | ✗ (account required) | **✓ via private iCloud** |
| **No ads, no tracking** | partial (no privacy detail verified) | partial (privacy details not provided) | ✗ (ads in free tier) | **✓** |
| **Extracurricular activities in the same view** | ✗ | ✗ | ✗ | **✓** |
| **Open source** | ✗ | ✗ | ✗ | **✓** |
| Recurring items | ✗ (requested) | ✗ | ✓ | ✓ |
| Home Screen widgets | ✗ | ✗ (requested) | partial (Premium) | ✓ (later MVP) |
| Cross-platform (Android, Windows, web) | ✓ | ✗ | ✓ | ✗ (by design) |
| Teacher-published assignments | ✗ | ✗ | ✓ | ✗ |

Cells marked "✗" for competitors mean the feature was not found in the
listing text or reviews reviewed, not that its absence was confirmed.

### 4.4 Positioning

Egenda and Homework Pal show that students value a free, simple homework
list, so "free and clean" alone will not set HomeworkPal apart. myHomework
shows that students want sync, calendar access, and widgets, but it charges
for them and requires an account. HomeworkPal is positioned between the two:
as simple as Egenda and Homework Pal, with the calendar and sync features
students ask for, offered free and without an account, and with
extracurriculars included so the app reflects the student's full week.

------------------------------------------------------------------------

## 5. Example Assignment Detail

An assignment detail screen could present information in the following form.

### Lab Report: Titration

**Class:** Chemistry (orange)\
**Type:** Paper\
**Due:** Thursday, Nov 12, 11:59 PM\
**Status:** Due in 3 days

**Notes:**\
Include error analysis. Submit as a PDF on the course portal. Partner: Jordan.

**Reminders:**\
Wednesday, 7:00 PM (evening before)\
Thursday, 4:00 PM (custom)

**Calendar:**\
✓ Added to Apple Calendar ("HomeworkPal" calendar) --- *Open in Calendar*

**Actions:**\
Mark Complete · Edit · Duplicate · Delete

The student can tap **Mark Complete** to check the assignment off. If the
assignment was added to Apple Calendar, the student is told what will happen
to the calendar event (kept, marked as done in its title, or removed, based
on their setting).

------------------------------------------------------------------------

## 6. MVPs and Representative Tasks

Each MVP below lists its goal, the differentiator it highlights, the screens
and user flows it introduces, and representative tasks. Tasks describe
realistic situations and are tagged **[Differentiator]** or **[Table stakes]**.

### MVP1: Private Homework Checklist That Lives in Your Calendar

**Goal:** Deliver the smallest genuinely useful homework tracker: add
assignments, see what is due, check them off, and put any due date in Apple
Calendar, all without an account.

**Uniqueness highlight:** From the first launch, the student gets a working
planner with no sign-up, no ads, and one-tap Apple Calendar integration,
which competitors either do not offer or charge for.

**Screens introduced:**

-   **Welcome / Privacy Promise** --- One screen shown on first launch:
    app name, a three-line promise ("No account. No ads. Your data stays on
    your device."), and a **Get Started** button. A "How we handle your data"
    link opens a short plain-language explanation.
-   **Add Your Classes (onboarding)** --- A short list where the student
    types class names and picks a color for each. Can be skipped and done
    later.
-   **Upcoming (home)** --- Assignments grouped into Overdue, Today,
    Tomorrow, This Week, and Later. Each row shows a checkbox, title, class
    color dot, type icon, and due date or time. A **+** button sits in the
    bottom corner. Empty state: "Nothing due. Tap + to add homework."
-   **Add / Edit Assignment (sheet)** --- Fields: title (focused
    automatically), class picker, type picker, due date with quick chips
    (Today, Tomorrow, In a week, Pick date), optional time, optional notes,
    and an **Add to Calendar** toggle.
-   **Assignment Detail** --- Full information as in Section 5, with
    Mark Complete, Edit, Delete, and Calendar status.
-   **Classes** --- List of classes with color, number of open
    assignments, and edit/archive options. Tapping a class shows its
    assignments.
-   **Completed** --- Checked-off assignments, newest first, with the
    option to un-check or delete.
-   **Settings** --- Default due time, calendar options, Privacy page,
    link to the open-source repository, and About.

**User flows introduced:**

-   *First launch:* Welcome / Privacy Promise → Add Your Classes (or skip)
    → Upcoming.
-   *Add assignment:* Upcoming → + → Add Assignment sheet → Save →
    returns to Upcoming with the new item in the correct bucket.
-   *Add to calendar:* Add Assignment (toggle on) or Assignment Detail →
    **Add to Calendar** → first time only, a pre-permission screen explains
    "HomeworkPal will only add events. It cannot see your other events." →
    system permission prompt → event created in the "HomeworkPal" calendar →
    confirmation with **Open in Calendar**.
-   *Complete:* Upcoming → tap checkbox (or swipe) → item animates out,
    with **Undo** shown briefly → item appears in Completed.

**Representative tasks:**

**MVP1 Task 1: Starting Without an Account [Differentiator]**\
Maya is a high school junior who stopped using her last planner app because
it kept asking her to sign up and showed ads between screens. She downloads
HomeworkPal and sees a single welcome screen explaining that there is no
account and her data stays on her phone. She taps Get Started, adds her six
classes with colors (blue for English, orange for Chemistry, green for
Biology), and lands on an empty Upcoming list within a minute.

**MVP1 Task 2: Adding Homework Right After Class [Table stakes]**\
As her Chemistry class ends, Maya's teacher assigns a lab report due
Thursday. Walking to her next class, she opens HomeworkPal, taps +, types
"Lab report: titration," picks Chemistry, taps the Pick date chip, chooses
Thursday, and saves. The whole entry takes under ten seconds, and the report
appears under This Week.

**MVP1 Task 3: Putting a Due Date in Apple Calendar [Differentiator]**\
Ethan is a college sophomore who plans his whole week in Apple Calendar.
When he adds "Econ problem set 4" due Friday at 5 PM, he turns on the Add to
Calendar toggle. The first time, HomeworkPal explains that it will only add
events and cannot read his calendar. Ethan allows access, and the due date
appears in a new "HomeworkPal" calendar, next to his lectures and work
shifts. He can now see that Friday is crowded and decides to start the
problem set Wednesday.

**MVP1 Task 4: Checking What Is Due Tomorrow [Table stakes]**\
On Sunday night, Maya opens HomeworkPal and sees two items under Tomorrow
and one under Overdue that she forgot to check off. She checks off the
overdue item, which moves to Completed, and plans her evening around the two
items due Monday.

**MVP1 Task 5: Finding Finished Work [Table stakes]**\
Ethan's professor asks whether he submitted last week's reading response. He
opens Completed and sees it was checked off Tuesday, with his note "submitted
via portal." Completed work stays available instead of disappearing.

**MVP1 Task 6: Checking How Data Is Handled [Differentiator]**\
Maya's parent asks whether the app collects her information. Maya opens
Settings → Privacy, which explains in plain language that data is stored on
the phone, nothing is sent to HomeworkPal, and there are no ads or tracking.
A link opens the public source code for anyone who wants to verify it.

------------------------------------------------------------------------

### MVP2: Reminders and a Calendar That Stays in Sync

**Goal:** Make sure students hear about due dates in time, and let the
calendar integration run automatically and stay accurate.

**Uniqueness highlight:** Due dates flow into Apple Calendar automatically
and update themselves when plans change, so the student's calendar is always
correct, which no free competitor offers.

**Screens introduced:**

-   **Notification permission prompt (in context)** --- Shown the first
    time the student adds a reminder, not on first launch, with a one-line
    explanation of why.
-   **Reminder options (in Add / Edit Assignment)** --- Quick choices:
    None, Morning of, Evening before (default time adjustable), Custom
    (date and time), plus the option to add more than one reminder.
-   **Reminder Settings** --- Default reminder for new assignments, default
    "evening before" time, and an optional **Daily Summary** notification
    ("3 things due tomorrow") at a chosen time.
-   **Calendar Settings** --- Three choices: *Off*, *Ask each time* (MVP1
    behavior), or *Add all due dates automatically*. Options for what
    happens to an event when an assignment is completed (keep, mark ✓ in the
    title, or remove) and which calendar to use. A **Sync status** row shows
    the last update and any problems.
-   **Notification actions** --- From a reminder notification, the student
    can choose **Mark Complete** or **Snooze 1 hour** without opening the app.

**User flows introduced:**

-   *Set a reminder:* Add Assignment → Reminder → Evening before → (first
    time) notification permission explanation → system prompt → saved.
-   *Act on a reminder:* Notification arrives → long-press → Mark Complete
    (item moves to Completed) or Snooze.
-   *Turn on automatic calendar sync:* Settings → Calendar → Add all due
    dates automatically → explanation that HomeworkPal now needs full
    calendar access so it can update and remove only its own events →
    system prompt → existing assignments added → confirmation showing how
    many were added.
-   *Edit with sync on:* Assignment Detail → Edit → change due date → Save
    → matching calendar event moves to the new date automatically.

**Representative tasks:**

**MVP2 Task 1: Getting Warned the Night Before [Table stakes]**\
Maya adds a history essay due Wednesday and selects the Evening before
reminder. On Tuesday at 7 PM, her phone shows "History essay is due
tomorrow." She already finished it, so she long-presses the notification
and taps Mark Complete.

**MVP2 Task 2: Sending Every Due Date to the Calendar [Differentiator]**\
Ethan is tired of turning on the calendar toggle for every assignment. He
opens Settings → Calendar and chooses Add all due dates automatically.
HomeworkPal explains why it now needs full calendar access and that it will
change only events it created. After he allows access, his twelve open
assignments appear in Apple Calendar at once.

**MVP2 Task 3: Updating a Due Date When Plans Change [Differentiator]**\
Ethan's professor extends the Econ problem set by two days. He opens the
assignment, changes the due date from Friday to Sunday, and saves. When he
checks Apple Calendar later, the event has already moved to Sunday. He never
has to fix his calendar by hand.

**MVP2 Task 4: Completing Work Without Cluttering the Calendar
[Differentiator]**\
Maya prefers a clean calendar. In Calendar Settings she chooses Remove event
when completed. When she checks off her lab report, its calendar event
disappears, while unfinished work stays visible.

**MVP2 Task 5: A Daily Summary at Dinner [Table stakes]**\
Jordan, a high school senior, turns on the Daily Summary at 6 PM. Each
evening he receives one notification listing what is due tomorrow, instead
of several separate alerts.

------------------------------------------------------------------------

### MVP3: Homework and Extracurriculars in One Week

**Goal:** Add extracurricular activities and recurring items, and show
students their full week, so the app addresses both halves of the problem in
the idea draft.

**Uniqueness highlight:** The student sees homework deadlines and activity
times together in one Week view and can spot overloaded days before they
arrive, which no competing homework app shows.

**Screens introduced:**

-   **Activities** --- A list next to Classes (a segmented control at the
    top of the screen: Classes | Activities). Each activity has a name,
    color, icon (sport, music, club, job, other), and an optional repeating
    schedule.
-   **Add / Edit Activity** --- Name, color, icon, repeat days (Mon--Sun
    toggles), start and end time, start and end date (for example, a fall
    season), and location (optional, text only).
-   **Activity To-Do (in Add / Edit)** --- Items can now be attached to
    an activity instead of a class, for example "Bring permission form" for
    Soccer. These appear in Upcoming like homework, with the activity's
    color.
-   **Week view** --- A new main tab. Each day is a row showing activity
    time blocks and homework due on that day. Days with many items show a
    **Busy** label based on simple counts (for example, three or more items
    or an activity plus two due dates). Tapping a day expands it to show
    every item. Arrows move to the previous or next week.
-   **Repeat options (in Add / Edit Assignment)** --- Repeat weekly on
    selected days, until a chosen end date, for recurring work such as
    weekly problem sets.

**User flows introduced:**

-   *Add an activity:* Classes/Activities → Activities → + → name, color,
    icon, repeat schedule → Save → activity times appear in Week view.
-   *Plan the week:* Week tab → scan days → see "Busy" on Tuesday → tap
    Tuesday → see rehearsal 4--7 PM and a lab report due → go back to the
    lab report and set a reminder for Monday.
-   *Add a recurring assignment:* + → "Calc problem set" → Repeat weekly,
    Friday, until Dec 12 → Save → future copies appear under Later and This
    Week as each date approaches.
-   *Send activities to the calendar (optional):* Activity editor → Add to
    Calendar → repeating event created in the "HomeworkPal" calendar.

**Representative tasks:**

**MVP3 Task 1: Adding a Practice Schedule [Differentiator]**\
Liam is a high school sophomore on the cross-country team. He opens
Activities, taps +, enters "Cross-country practice," picks green and the
running icon, and sets it to repeat Monday through Thursday from 3:30 to
5:30 PM until November 20. His practices now appear in the Week view.

**MVP3 Task 2: Spotting a Crowded Day [Differentiator]**\
On Sunday, Liam opens the Week view and sees Wednesday marked Busy: practice,
a Spanish quiz, and an English reading response all fall on that day. He
moves his reading to Tuesday night by setting a Tuesday reminder, and the
week looks more manageable.

**MVP3 Task 3: Remembering Activity To-Dos [Differentiator]**\
Ava is in the school musical. She adds "Turn in costume measurements" to her
Theater activity, due Friday. It appears in Upcoming alongside her homework,
in Theater's purple color, and she gets the same reminders she uses for
assignments.

**MVP3 Task 4: Setting Up a Weekly Problem Set Once [Table stakes]**\
Ethan's calculus class has a problem set due every Friday. Instead of adding
it every week, he creates it once and sets it to repeat weekly on Fridays
until the end of the semester. Each week's copy can be checked off on its
own.

**MVP3 Task 5: Balancing a Job and Classes [Differentiator]**\
Priya is a college junior who works three shifts a week at the campus
library. She adds "Library shift" as an activity with its usual days and
times. The Week view now shows her shifts alongside her due dates, so she
can see that Thursday's shift and Friday's paper deadline leave her only
Wednesday night to write.

------------------------------------------------------------------------

### MVP4: Private iCloud Sync, Backup, and At-a-Glance Access

**Goal:** Let students use HomeworkPal across their Apple devices and protect
their data, while keeping the no-account privacy promise, and make due dates
visible without opening the app.

**Uniqueness highlight:** The student's planner syncs across iPhone, iPad,
and Mac through their own private iCloud, with no account and no
HomeworkPal servers, which addresses the sync complaint competitors leave
unsolved or put behind an account.

**Screens introduced:**

-   **Sync & Backup** --- A switch for **iCloud Sync** with a short
    explanation ("Your data is stored in your private iCloud. HomeworkPal
    cannot see it."). Shows the last sync time and the devices using it.
    Includes **Export data** (a file the student can save or share) and
    **Import data**.
-   **Privacy Center** --- An expanded version of the MVP1 Privacy page:
    where data is stored (this device, iCloud if on), what permissions are
    granted (Calendar, Notifications) with links to change them, and a
    **Delete all data** option with confirmation.
-   **iPad and Mac layouts** --- Upcoming and Week views use the larger
    screen with a sidebar (Upcoming, Week, Classes, Activities, Completed)
    and a detail pane.
-   **Home Screen and Lock Screen widgets** --- *Due Soon* (next three to
    five items with class colors), *Today* (count of items due today), and
    *Next Up* (Lock Screen, the single nearest due item). Tapping a widget
    item opens its detail; on supported systems, a checkbox lets the student
    complete it directly.

**User flows introduced:**

-   *Turn on sync:* Settings → Sync & Backup → iCloud Sync on → existing
    data uploads → open HomeworkPal on iPad → same data appears with no
    sign-in.
-   *Recover after a new phone:* Install HomeworkPal on the new phone →
    welcome screen detects iCloud data → "Restore your planner?" → Restore
    → Upcoming shows the student's assignments.
-   *Export:* Sync & Backup → Export data → share sheet → save to Files or
    send.
-   *Add a widget:* Home Screen → edit → HomeworkPal → choose Due Soon →
    widget shows upcoming items.

**Representative tasks:**

**MVP4 Task 1: Using HomeworkPal on Phone and iPad [Differentiator]**\
Sofia, a college freshman, takes notes on her iPad in class and checks her
phone between classes. She turns on iCloud Sync on her phone, opens
HomeworkPal on her iPad, and sees the same assignments without signing up
for anything. When she adds a reading assignment on the iPad during class,
it appears on her phone a moment later.

**MVP4 Task 2: Getting Everything Back on a New Phone [Differentiator]**\
Maya's phone breaks mid-semester. On her replacement, she installs
HomeworkPal and is offered to restore her planner from iCloud. One tap later,
her classes, activities, assignments, and completed items are back.

**MVP4 Task 3: Checking Due Dates From the Home Screen [Table stakes]**\
Liam adds the Due Soon widget to his Home Screen. Each time he unlocks his
phone, he sees his next four due items in their class colors, and he checks
one off directly from the widget after turning it in.

**MVP4 Task 4: Leaving No Trace [Differentiator]**\
At the end of the school year, Jordan decides to switch to a paper planner.
He opens the Privacy Center, exports his data as a file for his records, and
taps Delete all data. HomeworkPal removes his data from the device and from
his iCloud, and removes the events it created in his calendar.

------------------------------------------------------------------------

## 7. Calendar and Privacy Behavior

Because calendar integration and privacy are HomeworkPal's main
differentiators, their behavior should be predictable and clearly explained.

**Calendar behavior**

-   HomeworkPal writes only to its own "HomeworkPal" calendar (or another
    calendar the student picks). It never edits or deletes events it did not
    create.
-   In MVP1, the app asks only for permission to add events. Automatic
    updates in MVP2 need wider access; the app asks for it only when the
    student turns that setting on, and explains why.
-   Each assignment's calendar event is an all-day event when no due time is
    set, and a short timed event ending at the due time when one is set.
-   When an assignment is edited, its event updates. When it is completed,
    the event follows the student's setting (keep, mark ✓, or remove). When
    it is deleted, the event is removed.
-   If the student turns calendar sync off, HomeworkPal asks whether to keep
    or remove the events it already created.

**Privacy behavior**

-   No account, sign-in, email address, or personal profile is required.
-   No advertising and no third-party analytics or tracking tools.
-   Data is stored on the device. When iCloud Sync is on, data is stored in
    the student's private iCloud, which HomeworkPal's developer cannot
    access.
-   Notifications are scheduled on the device; no server sends them.
-   The student can export or permanently delete all data at any time.
-   The source code is public so these statements can be checked.

------------------------------------------------------------------------

## 8. Recommended Usage Model

HomeworkPal's daily use can be summarized as:

**Capture → See → Schedule → Remind → Complete → Plan the Week**

-   **Capture:** add an assignment in seconds, right when it is assigned.
-   **See:** open the app to a list ordered by urgency.
-   **Schedule:** place due dates in Apple Calendar.
-   **Remind:** get notified before it is too late.
-   **Complete:** check items off and keep a record.
-   **Plan the Week:** see homework and activities together.

MVP1 covers Capture, See, Schedule, and Complete. MVP2 adds Remind and
automatic scheduling. MVP3 adds Plan the Week. MVP4 extends all stages
across devices and to the Home Screen.

An important design principle is that **speed of entry matters more than
detail**. If adding an assignment takes too long, students stop doing it,
and the planner becomes incomplete and untrustworthy. Every optional field
should stay optional, and sensible defaults (default due time, default
reminder, last-used class) should reduce typing.

------------------------------------------------------------------------

## 9. MVP Scope and Development Priorities

  Feature                                                        Development Phase
  -------------------------------------------------------------- -------------------
  No-account first launch with privacy promise                   MVP1
  Classes with names and color labels                            MVP1
  Add, edit, and delete assignments (title, class, type, due)    MVP1
  Quick due-date chips (Today, Tomorrow, In a week)              MVP1
  Upcoming list grouped by Overdue/Today/Tomorrow/Week/Later     MVP1
  Mark complete with undo; Completed view                        MVP1
  One-tap "Add to Apple Calendar" (add-only permission)          MVP1
  Dedicated "HomeworkPal" calendar                               MVP1
  Plain-language Privacy page; link to source code               MVP1
  Local due-date reminders (morning of, evening before, custom)  MVP2
  Multiple reminders per assignment                              MVP2
  Daily Summary notification                                     MVP2
  Mark Complete / Snooze from notification                       MVP2
  Automatic calendar sync of all due dates                       MVP2
  Calendar events update on edit, complete, or delete            MVP2
  Activities with color, icon, and repeating schedule            MVP3
  To-dos attached to activities                                  MVP3
  Week view combining homework and activities                    MVP3
  "Busy day" indicator                                           MVP3
  Recurring assignments                                          MVP3
  Optional calendar events for activities                        MVP3
  Private iCloud sync across iPhone, iPad, and Mac               MVP4
  Restore from iCloud on a new device                            MVP4
  Data export and import                                         MVP4
  Privacy Center with delete-all-data                            MVP4
  iPad and Mac layouts                                           MVP4
  Home Screen and Lock Screen widgets                            MVP4
  Siri and Shortcuts ("Add homework")                            Future
  Apple Watch complication                                       Future
  Import from Apple Calendar or class schedules                  Future
  Learning-management-system import (Canvas, Google Classroom)   Future / to be decided

For the first version, everything runs on the device with no server. This
keeps the app free to operate, which supports the promise that it will stay
free, and makes the privacy claims simple to verify.

------------------------------------------------------------------------

## 10. Conclusion

HomeworkPal aims to help high school and college students stop losing track
of homework, projects, and extracurricular commitments through a fast, clean
checklist that works with Apple Calendar, reminds students before due dates,
and shows their whole week in one place.

The central objective of MVP1 is to demonstrate a complete daily loop:

**add an assignment in seconds, see what is due by urgency, put it in your
calendar, and check it off, with no account and no ads.**

Later versions keep the calendar current automatically, bring
extracurriculars into the same view, and sync across the student's Apple
devices through their own private iCloud.

Competing apps show that students value free, simple homework tracking, but
they leave real gaps: calendar access and sync are paid or tied to an
account, privacy is unclear, and activities are left out. By combining
**free calendar integration, account-free privacy, homework and activities in
one week, and an open-source, Apple-native design**, HomeworkPal can offer
students a planner they can both rely on and trust.

------------------------------------------------------------------------

## 11. Assumptions & Open Questions

### App name

-   **"HomeworkPal" conflicts with an existing competitor.** The draft's
    name is nearly identical to **Homework Pal** (Chris Houston, App Store ID
    1340538392), one of the three competitors listed. The App Store requires
    unique app names, and the similarity is likely to cause confusion and
    possible trademark problems. This document uses "HomeworkPal" because the
    draft specified it, but renaming before launch is strongly recommended.
    Alternatives (not yet checked for existing App Store or trademark
    conflicts):
    -   **DueDay** --- Short and direct; centers on the app's core
        question, "what is due, and when?"
    -   **Satchel** --- A school bag that holds everything; friendly and
        not tied only to homework, which suits activities too.
    -   **Plainplan** --- Signals the clean, simple, no-strings design and
        privacy stance.

### Assumptions made to fill gaps

-   Extracurriculars are mentioned only in the draft's Background. They were
    treated as a core feature (MVP3) because they are the clearest gap among
    competitors. Confirm that they belong in scope.
-   "Work with your Apple calendar" was interpreted as **one-way**: HomeworkPal
    adds and updates its own events. Reading events from the calendar (for
    example, importing class times) was left as a future feature.
-   "Designed for Apple" was taken to mean iPhone first, with iPad and Mac
    layouts in MVP4. Apple Watch was left as a future feature.
-   Notifications were placed in MVP2 rather than MVP1 to keep MVP1 focused on
    the differentiators. If testers find MVP1 unusable without reminders, a
    single "evening before" reminder could move into MVP1.
-   Assignment types (homework, project, quiz, test, paper, other) and the
    time buckets (Overdue/Today/Tomorrow/This Week/Later) were chosen as
    reasonable defaults.
-   Data loss before MVP4 is assumed to be covered by the student's normal
    iPhone backup; confirm this is acceptable.

### Decisions still needed

-   Final app name (see above).
-   Open-source license (for example, MIT, Apache 2.0, or GPL) and where the
    repository will be hosted.
-   Minimum iOS version. Add-only calendar permission and some widget
    interactions depend on newer iOS versions.
-   Default behavior for calendar events when an assignment is completed
    (keep, mark ✓, or remove).
-   Whether the "Busy" day rule should be simple counts (as proposed) or let
    students set their own threshold.
-   Whether any privacy-preserving crash reporting will be used, and how it
    is disclosed. The document assumes none.
-   How the project will be sustained with no revenue (for example, optional
    tips or donations), if at all.

### Unclear or contradictory parts of the draft

-   The draft says users would not pay because "it's free," which explains
    the pricing but not why students would choose it over Egenda and Homework
    Pal, which are also free. The Innovation section addresses this with
    calendar, privacy, sync, and activities instead.
-   "Data is not shared and kept local, with the option to back it up to
    iCloud" was read as full **sync** across devices, not only a backup copy.
    Confirm whether sync or backup-only is intended.

### Competitor research limitations

-   No Sensor Tower links were provided; the draft lists App Store links
    instead. The App Store pages could not be opened directly from this
    environment. Competitor details come from App Store listing text shown in
    search results and from third-party sites (AppFollow, AppGoblin,
    AppsHunter, Justuseapp, and reviews by educational sites). Downloads,
    revenue, ranking trends, and official privacy labels were therefore not
    verified. Providing Sensor Tower pages would allow a firmer market
    analysis.
-   Install, user, and revenue figures from AppGoblin are third-party
    estimates.
-   Features marked ✗ for competitors were not found in available listing
    text or reviews; their absence was not confirmed by using the apps.

### Competitor-inspired additions beyond the draft

-   **Recurring items** (MVP3): requested in Egenda reviews and needed for
    repeating activities.
-   **Completed view** (MVP1): a Homework Pal review praised it compared
    with Egenda, where completed items disappear.
-   **Widgets** (MVP4): requested in Homework Pal and myHomework reviews;
    paid in myHomework.
-   **Daily Summary notification** (MVP2): based on Egenda's daily "due
    tomorrow" reminder.
-   **Data export and delete-all** (MVP4): added to support the privacy
    promise; not requested by the draft.

### Draft innovation points that overlap with existing apps

-   **"It's free."** Egenda and Homework Pal are already free, and
    myHomework's core is free. Sharpen this to *"free with nothing locked":
    calendar, sync, and widgets included, with no ads.*
-   **"Clean, easy-to-use modern UI."** All three competitors describe
    themselves as simple or beautiful. Treat it as table stakes and make it
    measurable instead, for example *"add an assignment in under ten
    seconds."*
-   **"Designed for Apple."** Homework Pal is also Apple-only. The real
    difference is deep use of Apple features (Calendar, iCloud, widgets,
    notification actions), so name those specifically.
-   **"Open source."** Not offered by the competitors reviewed, but most
    students will not notice it. Present it as the *proof* behind the privacy
    promise rather than as a stand-alone feature.
-   **"Private / local data with iCloud backup."** This is the strongest
    point. Egenda reviewers ask for sync and myHomework ties sync to an
    account. Lead with *"sync across your Apple devices with no account."*
