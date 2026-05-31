SOFTWARE REQUIREMENTS SPECIFICATION
AthletiTrack: Athlete Training Monitoring System
Prepared by:
LCB-Tech
___________________________
___________________________
___________________________
Course: Bachelor of Science in Information Technology
Subject: Software Engineering
Instructor: ___________________________
Institution: Eastern Visayas State University
Date: May 2026
AthletiTrack-SRS – LCB-Tech – Page 2

1. INTRODUCTION
1.1 Purpose
This Software Requirements Specification (SRS) defines the complete functional and nonfunctional requirements for AthletiTrack, an Athlete Training Monitoring System. The
system is designed to enable remote monitoring of athlete training by coaches who cannot
always be physically present. The project is developed as part of the Software Engineering
course at Eastern Visayas State University (EVSU).
This document is based on surveys and interviews conducted with respondents from the
University of Santo Tomas and the Philippine National Taekwondo Team. All requirements
are derived from the expressed needs of coaches and athletes, and from the development
team’s understanding of the problem.
This SRS is intended for the development team (LCB-Tech), the course instructor, and the
stakeholder representatives. It serves as the contractual agreement of project scope and the
foundation for design, implementation, and testing.
1.2 Scope
AthletiTrack is a cross-platform application built with Flutter, available as an Android APK
and a responsive web application. It replicates the workflow of Google Classroom but
tailored for sports coaching: coaches can create teams, set one-time or recurring weekly
training schedules, make announcements, and monitor athlete compliance through submitted
proof. Athletes can join teams, view training posts, upload proof of training (images, videos,
documents), submit excuses, comment, and receive reminders.
The system addresses the core problem: coaches who are also teachers or have other
commitments cannot always supervise training in person. AthletiTrack allows them to track
attendance, verify training completion, and maintain communication entirely online.
The system supports two user roles: Coach and Athlete. It does not include push notifications,
direct chat, athlete-to-athlete messaging, or integration with external school databases in this
version.
AthletiTrack-SRS – LCB-Tech – Page 7
1.3 Definitions, Acronyms, and Abbreviations
Term / Acronym Definition
AthletiTrack The proposed Athlete Training Monitoring System
Coach A user who creates teams, schedules training, and monitors
athletes
Athlete A user who joins teams, views schedules, and submits training
proof
Team A group created by a coach that athletes can join via a unique
code
Training Session A scheduled event; can be one-time (specific date/time) or
weekly (recurring)
OTP One-Time Password – a code sent to email for account
verification
Flutter Google’s UI toolkit for building natively compiled applications
for mobile and web
PHP Server-side scripting language used for backend API
Supabase Open-source Firebase alternative providing PostgreSQL database
and API
PHP Mailer Library for sending emails from PHP via SMTP
SRS Software Requirements Specification
FR Functional Requirement
NFR Non-Functional Requirement
UC Use Case
US User Story
ER Entity-Relationship
SDG Sustainable Development Goal
GAD Gender and Development
JWT JSON Web Token
CSRF Cross-Site Request Forgery
RBAC Role-Based Access Control
SUS System Usability Scale
AthletiTrack-SRS – LCB-Tech – Page 8
1.4 References
• Interview responses from coaches and athletes of the Philippine National Taekwondo
Team and UST students, April–May 2026.
• Google Classroom feature reference – used as a comparative model by stakeholders.
• Flutter Documentation. Available at: https://flutter.dev/docs
• Supabase Documentation. Available at: https://supabase.com/docs
• PHP Mailer Documentation. Available at: https://github.com/PHPMailer/PHPMailer
1.5 Document Overview
This SRS contains twelve sections. Section 1 provides the introduction, scope, definitions,
SDG alignment, and GAD compliance. Section 2 describes the overall system context,
features, user classes, and constraints. Section 3 details use case scenarios. Section 4 presents
user stories with acceptance criteria. Section 5 specifies all functional requirements and
detailed logic for attendance and recurring schedules. Section 6 defines non-functional
requirements including security, scalability, and offline synchronization. Section 7 outlines
the system architecture and technology stack. Section 8 covers interface requirements.
Section 9 describes the data model and integrity rules. Section 10 defines the testing strategy.
Section 11 lists measurable acceptance criteria. Section 12 contains appendices with diagrams
and the traceability matrix.
1.6 Sustainable Development Goals (SDG) Alignment
AthletiTrack directly contributes to the United Nations Sustainable Development Goals,
specifically SDG 3 and SDG 9. This alignment demonstrates that the system is not only a
technical solution to a training management problem but also a tool that supports broader
societal and institutional objectives.
SDG 3 – Good Health and Well-being. AthletiTrack promotes physical health and well-being
by enabling structured, consistent athletic training. Through scheduled one-time and weekly
training sessions, coaches can ensure athletes maintain regular exercise routines, reducing the
likelihood of inactivity and its associated health risks. The proof-upload and approval
workflow verifies that training actually occurs, encouraging genuine engagement rather than
self-reported compliance. The attendance and progress analytics further enable coaches to
detect training gaps and intervene, preventing undertraining or overtraining that could lead to
AthletiTrack-SRS – LCB-Tech – Page 9
injury. By making health-promoting behaviour trackable and accountable, the system directly
supports the target of reducing non-communicable diseases through physical activity.
SDG 9 – Industry, Innovation and Infrastructure. AthletiTrack leverages modern crossplatform infrastructure and digital innovation in sports management. Built with Flutter for a
unified codebase across Android and the web, a PHP REST API backend, and a Supabase
PostgreSQL database, the system exemplifies resilient, inclusive, and sustainable software
infrastructure. It relies on cloud-based services that scale affordably, making advanced
training management accessible even to small university teams with limited budgets. The
system introduces innovation by digitising a traditionally manual, trust-based monitoring
process, replacing it with verifiable, data-rich workflows. This contributes to the target of
upgrading technological capabilities in educational and sports institutions, fostering an
innovation ecosystem where digital tools enhance operational efficiency.
1.7 Gender and Development (GAD) Compliance
AthletiTrack is designed with an explicit commitment to gender equality and inclusive
development, in compliance with the principles of Gender and Development (GAD) as
promoted by Philippine educational institutions. The system’s architecture, user experience,
and administrative workflows ensure that no user is disadvantaged on the basis of gender.
Inclusive athlete management. The system does not restrict any feature based on gender.
Coaches can create teams that include athletes of any gender identity; the optional team
category field (e.g., “Men’s”, “Women’s”, “College”, “Senior High”) is purely descriptive
and does not impose functional limitations. Athletes of all genders have identical registration,
dashboard, and interaction capabilities. The skill-level tagging system
(Beginner/Intermediate/Expert) allows performance-based grouping that avoids gendered
assumptions about athletic ability.
Equal access and non-discriminatory monitoring. The attendance table, proof review, and
progress analytics treat all athletes identically. Coaches cannot apply different approval
criteria or viewing permissions based on gender; every athlete’s submission undergoes the
same verification workflow. The system does not collect or display gender-specific data
unless the coach voluntarily includes it in a team’s descriptive category, and such data is
never used to filter or restrict system functionality.
AthletiTrack-SRS – LCB-Tech – Page 10
Gender-sensitive design considerations. The user interface follows material design guidelines
and uses neutral colour palettes, iconography, and language that avoid gender stereotyping.
All notifications, error messages, and labels use gender-neutral terms (e.g., “athlete”, “user”,
“coach”). The system does not assume or require the user to disclose their gender during
registration; only name, email, and password are mandatory, preventing any unintended bias
in onboarding.
By embedding these principles, AthletiTrack ensures equitable sports administration and
aligns with institutional GAD policies, fostering an environment where all athletes can be
monitored, evaluated, and supported solely on the basis of their training effort and
performance.
AthletiTrack-SRS – LCB-Tech – Page 11
2. OVERALL DESCRIPTION
2.1 Product Perspective
AthletiTrack is a new, standalone system developed to solve a documented operational gap in
remote sports coaching. Coaches frequently cannot attend every training due to other
professional duties (e.g., teaching). Athletes need a structured way to receive training
schedules, submit proof of completion, and remain accountable. The system acts as a virtual
training management platform, similar to how Google Classroom manages class assignments.
The application consists of a Flutter frontend (Android APK and web) that communicates
with a PHP REST API backend. All persistent data is stored in a Supabase PostgreSQL
database, accessed via its API. Authentication is role-based, with email OTP verification
using PHP Mailer and Gmail SMTP.
2.2 Product Features
• Role-based registration and login with email OTP verification for both Coaches and
Athletes.
• Coach dashboard with slide-out menu (profile, about, logout), team creation, and
horizontally scrollable team cards.
• Team management: create team with name, description, optional logo; generate
unique team code; view pending join requests; approve/reject athletes.
• Post creation: Coach can create an announcement (text only) or a training session.
• Training session types:
o One-time session: specific date, time, and optional description.
o Weekly schedule: recurring days (e.g., M-W-F) with time range; overwrites
previous default after confirmation.
• Training cards: displayed as scrollable cards; click opens modal with full details,
day-of-week indicators (green for scheduled, red otherwise).
• Athlete dashboard: similar UI; join team via code; view announcement and training
cards in a feed.
• Training interaction: Athletes can upload proof (images, videos, documents),
comment, mark as done, submit excuse files, and set a 5-minute reminder.
• Attendance tab: per-team dynamic table showing athlete names vs. training sessions;
cells turn green (approved proof) or red (missing/rejected); one-time sessions inserted
automatically; weekly sessions recorded only after occurrence.
AthletiTrack-SRS – LCB-Tech – Page 12
• Export to Excel: coach can export attendance table.
• Calendar view: coaches see all scheduled training sessions in calendar format.
• Responsive UI: smooth card scrolling, modal popups, animated slide menus, mobilefirst design.
• Offline data caching: previously loaded schedules and announcements remain
viewable offline after initial sync.
2.3 User Classes and Characteristics
User
Type Role Technical Skill Level Primary Device
Coach
Creates teams, schedules
training, monitors
attendance, approves
proof
Moderate – familiar with
Google Classroom and
web forms
Mobile (Android) or
desktop web
Athlete
Joins teams, views
schedules, uploads proof,
sets reminders
Basic – can navigate
apps, upload files, join
via code
Mobile (Android)
primarily; desktop web
optional
Both user groups are assumed to have daily experience with applications like Google
Classroom.
2.4 Operating Environment
• Frontend: Flutter application compiled as Android APK and responsive web (mobile
and desktop).
• Backend: PHP REST API hosted on Render.com (or similar free-tier cloud service).
• Database: Supabase (PostgreSQL) accessed via Supabase client API.
• Email: PHP Mailer configured with Gmail SMTP (TLS, port 587) for OTP and
notifications.
• Client devices:
o Android smartphones running Android 8.0 or later.
o Modern web browsers (Chrome, Firefox, Safari) for the web version.
• Internet: Required for registration, login, joining teams, posting, and syncing.
Cached content is available offline.
AthletiTrack-SRS – LCB-Tech – Page 13
2.5 Design Constraints
• The frontend must be built entirely with Flutter for cross-platform consistency.
• The backend must be implemented in PHP; no alternative server-side frameworks are
used.
• Database interaction is exclusively through Supabase API; direct SQL connections are
not permitted from the client.
• Real-time features (e.g., live chat, push notifications) are out of scope for the initial
version.
• The system must operate within free-tier hosting limitations of Render.com and
Supabase.
• iOS support is not included; only Android and web are targeted.
• The development team consists of three members with intermediate skills; the
codebase must remain simple and maintainable.
2.6 Assumptions and Dependencies
• All users own a smartphone or have regular access to a computer with a stable
internet connection.
• Users check their email regularly for OTP and join requests.
• Coaches will actively manage pending join requests.
• The system depends on Gmail SMTP availability; email delivery failures will not
crash the system but may delay account verification.
• The system depends on Render.com uptime (free tier). Supabase availability is also a
dependency.
• Basic understanding of app navigation is assumed; no formal training is provided.
AthletiTrack-SRS – LCB-Tech – Page 14
3. USE CASE SCENARIOS
UC-01: Register as Coach
Actor: Coach
Description: A new coach creates an account by providing name, email, and password. The
system sends an OTP to the email, and after verification the coach is automatically logged in.
Preconditions: Coach has the AthletiTrack app open on the registration screen.
Trigger: Coach taps “Register as Coach”.
Main Success Scenario:
1. Coach fills in name, email, password.
2. System validates email format and password strength.
3. System sends a 6-digit OTP to the provided email via PHP Mailer.
4. Coach enters OTP within 5 minutes.
5. System verifies OTP, creates coach account (password hashed with bcrypt).
6. System automatically logs coach in and redirects to the dashboard.
Alternative Flows:
A1 – Invalid email or weak password: System shows descriptive error, blocks submission.
A2 – OTP expired/invalid: Coach can request a new OTP. After 3 failed attempts, cooldown
of 10 minutes.
Postconditions: Coach account exists and is logged in.
UC-02: Create Team and Generate Team Code
Actor: Coach
Description: Coach creates a new team from the dashboard. A unique team code is generated
for athletes to join.
Main Success Scenario:
1. Coach taps “+” button on dashboard.
2. Coach selects “Create Team”.
3. Coach enters team name, description, and optionally uploads a logo.
4. System saves team and generates a unique alphanumeric code.
5. System displays the team card on the dashboard.
Alternative Flows:
A1 – Missing required fields: System highlights name field, prevents saving.
Postconditions: New team appears on coach’s dashboard; team code visible in team page.
AthletiTrack-SRS – LCB-Tech – Page 15
UC-03: Create Training Session (One-Time or Weekly)
Actor: Coach
Description: Inside a team page, coach creates a training post.
Main Success Scenario:
1. Coach opens team page and taps “Create Post”.
2. Coach selects “Training Session”.
3. Coach chooses type: One-Time or Weekly Schedule.
4. For One-Time: enters date, time, optional description.
5. For Weekly: selects days of week (M,T,W…), start-end time; optional description.
6. If weekly schedule already exists, system asks for overwrite confirmation.
7. System saves and displays training card in team feed.
Postconditions: Training card is visible to all approved team athletes.
UC-04: Athlete Joins Team via Code
Actor: Athlete
Description: Athlete enters a team code received from a coach; request is sent for approval.
Main Success Scenario:
1. Athlete taps “+” on dashboard.
2. Athlete selects “Join Team” and enters team code.
3. System validates code and sends join request to coach.
4. Coach receives notification in pending requests; approves.
5. Athlete’s dashboard updates with the new team card.
Postconditions: Athlete can view team feed and training posts.
UC-05: Athlete Submits Training Proof
Actor: Athlete
Description: For a one-time training session, athlete uploads proof and marks as done.
Main Success Scenario:
1. Athlete opens training card.
2. Athlete taps “Mark as Done” / “Upload Proof”.
3. Athlete selects file (image, video, or document) and enters optional message.
4. System uploads file to Supabase storage; proof record is linked to training session.
5. System notifies coach (next time coach views attendance).
AthletiTrack-SRS – LCB-Tech – Page 16
Alternative Flows:
A1 – Excuse submission: Athlete taps “Submit Excuse”, uploads excuse document, and
optionally explains; no “done” status.
Postconditions: Proof appears in attendance table; coach can approve/deny.
UC-06: Coach Reviews Attendance and Proof
Actor: Coach
Description: Coach opens attendance tab for a team, views statuses, approves/rejects proofs.
Main Success Scenario:
1. Coach navigates to team, taps “Attendance”.
2. System displays dynamic table: athlete rows, session columns with colored cells.
3. Coach taps a green cell to view submitted proof.
4. Coach reviews file, then taps “Approve” or “Reject”.
5. System updates cell status.
Postconditions: Attendance record updated; athlete can see result.
UC-07: View Training Schedule Calendar
Actor: Coach
Description: Coach sees all scheduled training sessions in a calendar view.
Main Success Scenario:
1. Coach navigates to Calendar from dashboard.
2. System fetches all one-time and recurring sessions for all teams.
3. Calendar displays colored dots on dates with sessions; tapping a date shows details.
Postconditions: Coach gains overview of schedule density.
UC-08: Export Attendance to Excel
Actor: Coach
Description: Coach exports the attendance table for a team as an .xlsx file.
Main Success Scenario:
1. Coach opens Attendance tab, taps “Export to Excel”.
2. System generates file containing all visible session columns and athlete rows with
statuses.
3. File downloads to device.
Postconditions: Coach has a portable record of training compliance.
AthletiTrack-SRS – LCB-Tech – Page 17
4. USER STORIES
The following user stories are grounded in survey responses collected from four coaches and
one athlete (April–May 2026), and a face-to-face interview conducted with a university
coach. The interview was conducted in Cebuano/Bisaya and translated for this document. All
stories reflect the expressed needs of the respondents.
US-01
User Story: As a coach, I want athletes to upload photo or video proof with an automatic
date and time stamp so that I can verify they completed their assigned drills correctly even
when I am not physically present.
Basis: Grounded in interview: the coach stated the need for "a monitoring system where
athletes send pictures or videos, and the app automatically records the date and time of
capture." Survey: 4 out of 4 coaches selected video as the preferred proof format.
Acceptance Criteria:
• Athlete can capture or upload photo/video from within the app.
• System automatically records and displays the date and time of upload.
• Proof is linked to the specific training session.
• Coach can view proof in the attendance table and tap to review the file.
• Supported formats: JPEG, PNG, MP4, PDF, DOC, DOCX.
US-02
User Story: As a coach handling multiple teams with different skill levels, I want to create
and manage separate training programs per team so that expert athletes and beginners receive
appropriate routines without confusion.
Basis: Grounded in interview: the coach manages multiple teams simultaneously and stated
"it's really different — for example, these are experts, these are beginners. You can't give
them the same training." Survey: 3 out of 4 coaches update routines weekly; training
frequency increases from twice a week to five to six times per week during competition
season.
Acceptance Criteria:
AthletiTrack-SRS – LCB-Tech – Page 18
• Coach can create multiple teams, each with its own name, category (e.g., Men's,
Women's, College, Senior High), and skill level label.
• Each team has its own feed of posts and training schedules.
• Athletes only see content for teams they have been approved to join.
Coach can set both one-time sessions and recurring weekly schedules per team.
US-03
User Story: As a coach, I want to see a clear attendance table showing who complied, who
did not, and their training progress over time so that I can adjust programs based on actual
performance data.
Basis: Grounded in interview: "there should be evidence of what they did — their jogging
time, drills, games, all of it should be included." Survey: all 4 coaches selected "consistency"
and "progress" as the data they most want to see. Coaches want to know if a 500 push-up
routine has become too easy so they can increase difficulty.
Acceptance Criteria:
• Attendance table shows athlete name, training session date/time, and compliance
status.
• Green cell: athlete submitted proof and coach approved.
• Red cell: athlete did not submit proof or proof was rejected.
• Table is dynamic: one-time sessions auto-populate; weekly sessions appear only after
the scheduled date passes.
• Coach can view an individual athlete's history: completed sessions vs. missed, proof
submitted over time.
• Progress indicators for measurable exercises are displayed where applicable.
US-04
User Story: As a coach, I want to approve or reject submitted training proof so that athletes
are held accountable and cannot simply claim they trained without evidence.
Basis: Grounded in interview: "there is currently no way to verify this. It is purely honest to
goodness. You ask them and they say 'yes sir' — but we cannot be 100% sure." Survey: 3 out
of 4 coaches stated they do not fully trust self-reports without proof.
Acceptance Criteria:
AthletiTrack-SRS – LCB-Tech – Page 19
• Submitted proof appears in the attendance table as a tappable cell.
• Coach can view the photo, video, or document, then tap Approve or Reject.
• Approved proof turns the cell permanently green.
• Rejected proof keeps the cell red with an optional coach note explaining the rejection.
• Athlete sees updated status after coach action.
US-05
User Story: As a coach, I want to know why an athlete missed training and have the option
to assign corrective action so that absences are addressed and not ignored.
Basis: Grounded in interview: the coach described giving extra laps as a consequence —
"instead of 10 laps, make it 15." Survey responses: "Find the reason, adjust if needed, hold
them accountable," "Give them punishments, for example 1000 squats for absent," "Confront
them as soon as possible and ask their clarification why they didn't attend."
Acceptance Criteria:
• Athlete can submit an excuse document with an explanation before or after a missed
session.
• Coach sees the excuse attached to the attendance record.
• Coach can leave a note or assigned corrective action visible to the athlete.
• Repeated absences are highlighted in the athlete's progress view for coach review.
US-06
User Story: As an athlete, I want to receive a reminder before my scheduled training session
so that I do not forget and can prepare on time.
Basis: Grounded in interview: "if there is a message to them, plus it could also tell them 'your
last jogging was 5 minutes.'" Survey: 6 out of 6 respondents (100%) stated reminders would
help athletes stay consistent with training.
Acceptance Criteria:
• Athlete can set a 5-minute reminder on any one-time training session.
• System triggers a local notification with session details at the set time.
• For weekly schedules, athletes are reminded before each scheduled occurrence.
• Coach can optionally send a manual announcement to the entire team.
AthletiTrack-SRS – LCB-Tech – Page 20
US-07
User Story: As a coach managing multiple teams across different categories, I want a
dashboard that shows all my teams at a glance so that I can switch between them quickly
without confusion.
Basis: Grounded in interview: the coach described handling separate categories — "for
example, college category here, senior high school there. Yes, those situations really exist."
The coach explicitly manages teams with distinct programs and athlete groups.
Acceptance Criteria:
• Dashboard displays all teams as horizontally scrollable cards with team name and
optional logo.
• Each card shows a summary: number of athletes and next scheduled training.
• Tapping a card opens that team's dedicated page with its own feed and settings.
• Coach can create a new team from the dashboard at any time using the "+" button.
US-08
User Story: As an athlete, I want to join my coach's team using a code so that I can access
my training schedules and submit proof without needing the coach to manually add me.
Basis: Derived from the logical requirement of multi-team management. Coaches managing
multiple teams with many athletes cannot manually add every individual. A join code system
is standard practice and mirrors Google Classroom, which all respondents use daily.
Acceptance Criteria:
• Athlete enters a team code provided by the coach via the "+" button on the dashboard.
• Join request is sent to the coach for approval.
• After coach approval, the team appears on the athlete's dashboard with full access to
posts and schedules.
• Coach can reject requests; athlete is notified of the result.
US-09
User Story: As a coach, I want to quickly increase training frequency when competition
season approaches so that the schedule reflects the two-to-three-week concentration period
without recreating everything from scratch.
AthletiTrack-SRS – LCB-Tech – Page 21
Basis: Grounded in interview: "when the event is near, like SCUAA, that is when you really
go for it — whole week, or two weeks before, sometimes I extend it to three weeks." Survey
confirms training increases from 1–2 times per week to 5–6 times per week during
competition season.
Acceptance Criteria:
• Coach can add multiple one-time training sessions during the pre-competition period.
• The default weekly schedule can be supplemented with additional sessions without
overwriting it.
• Calendar view clearly shows the increase in training density during concentration
weeks.
• Athletes see all added sessions in their team feed in chronological order.
US-10
User Story: As an athlete, I want to view my training schedule and previously loaded
announcements even without internet so that I can still follow the program when I am at a
training venue with poor signal.
Basis: Derived from logical requirement. Training venues such as courts, fields, and gyms do
not always have reliable internet connectivity. The system must not prevent athletes from
viewing their assigned routines due to network issues.
Acceptance Criteria:
• Previously loaded team feed content is cached locally on the device.
• Training cards, schedules, and announcements remain viewable when offline.
• A visible offline indicator is displayed at the top of the screen within 2 seconds of
connectivity loss.
• New proof uploads and post creation require an active internet connection; cached
viewing does not.
US-11
User Story: As a coach, I want to export attendance and progress data to Excel so that I can
maintain offline records and submit documentation to my department or sports office.
Basis: Grounded in interview context: the coach is also a faculty member in the Engineering
and IT departments. Documentation and reporting are part of institutional requirements.
AthletiTrack-SRS – LCB-Tech – Page 22
Survey: coaches selected "all of the above" when asked what data they want to see —
attendance, progress, and consistency.
Acceptance Criteria:
• Attendance table exports as a properly formatted .xlsx file.
• Export includes all athlete names, session columns, dates, and compliance statuses.
• File downloads directly to the coach's device upon tapping "Export to Excel."
• The exported data matches the current state of the attendance table on screen.
US-12
User Story: As a coach, I want to assign different training routines to different skill levels
within the same team so that beginners are not overwhelmed and experts remain challenged.
Basis: Grounded in interview: "it is really different — for example, these are the experts,
these are the beginners. You cannot give the experts the same training as the beginners."
Survey: one coach stated they want "more individual specific training for each athlete."
Acceptance Criteria:
• Coach can tag athletes within a team by skill level: Beginner, Intermediate, or Expert.
• Training posts can be set as visible to all skill levels or filtered to specific levels.
• Athletes only see posts relevant to their assigned skill level in their feed.
• Coach can update an athlete's skill level as they progress over time.
AthletiTrack-SRS – LCB-Tech – Page 23
5. FUNCTIONAL REQUIREMENTS
All requirements use the form 'The system shall...' and are numbered sequentially for
traceability.
FR-01: Coach Registration with Email OTP
Description: The system shall allow a coach to register by providing full name, email
address, and password. Upon submission, the system shall send a 6-digit OTP to the provided
email via PHP Mailer. After successful OTP verification, the system shall create the coach
account with a bcrypt-hashed password and automatically log in the coach.
Rationale: Email verification ensures only legitimate users create coach accounts. Automatic
login reduces friction for first-time use.
Acceptance Criteria:
• OTP is sent within 30 seconds of registration form submission.
• OTP expires after 5 minutes.
• After 3 failed OTP attempts, a 10-minute cooldown is enforced.
• Password is hashed using bcrypt before storage in Supabase.
• Coach is redirected to the dashboard immediately after successful verification.
FR-02: Athlete Registration with Email OTP
Description: The system shall allow an athlete to register using the same flow as FR-01, with
the user role automatically set to "Athlete" upon account creation.
Rationale: Athletes require the same secure onboarding as coaches. Separate registration
paths ensure correct role assignment from the start.
Acceptance Criteria:
• All criteria from FR-01 apply to athlete registration.
• Athlete role is correctly assigned and cannot be changed by the user.
FR-03: Role-Based Login and Session Management
Description: The system shall authenticate users by email and password. Upon successful
authentication, the system shall redirect the user to their role-specific dashboard: Coach to the
AthletiTrack-SRS – LCB-Tech – Page 24
team management dashboard, Athlete to the team feed dashboard. Sessions shall persist until
manual logout.
Rationale: Two distinct roles require different interfaces and permissions.
Acceptance Criteria:
• Valid credentials redirect to the correct role-specific dashboard.
• Invalid credentials display a plain-language error message within 1 second of
submission; the message must not indicate whether the email is registered. The error
message shall be tagged with a numeric code for logging (e.g., ERR_AUTH_002).
• Session token is stored securely and persists across app restarts until logout.
• No user can access features or data outside their assigned role.
FR-04: Coach Dashboard with Slide-Out Menu
Description: Upon login, the system shall display the coach dashboard with a hamburger
menu icon. Tapping the icon shall slide out a menu from the left containing: Profile, About
Us, and Logout. The dashboard shall have a floating action button ("+") for creating teams.
Rationale: The slide-out menu provides consistent navigation.
Acceptance Criteria:
• Menu slide-out animation completes in 250–400 milliseconds, maintaining a
consistent frame rate of at least 30 fps on a mid-range Android device (Snapdragon 6-
series or equivalent).
• Profile opens an editable view of coach details.
• About Us displays development team information.
• Logout ends the session and returns to the login screen.
• "+" button is always visible on the dashboard.
FR-05: Team Creation and Team Code Generation
Description: The system shall allow a coach to create a team by tapping the "+" button and
selecting "Create Team." The coach shall enter a team name (required), description
(optional), category (optional, e.g., Men's, Women's, College, Senior High), and an optional
team logo. Upon saving, the system shall generate a unique alphanumeric team code and
display the team as a card on the dashboard.
AthletiTrack-SRS – LCB-Tech – Page 25
Rationale: Coaches manage multiple teams across categories.
Acceptance Criteria:
• Team name is required; all other fields are optional.
• Team code is unique system-wide and displayed on the team page.
• Team card appears on the dashboard showing team name, logo (if set), and athlete
count.
• Cards are scrollable vertically when multiple teams exist.
FR-06: Team Page and Join Request Management
Description: Tapping a team card shall open the team page. The page shall display the team
name at the top, a button to view and share the team code, a button to view pending join
requests, and a "Create Post" button. Pending join requests shall list athlete names with
Approve and Reject actions.
Rationale: Coach needs to manage team membership actively.
Acceptance Criteria:
• Team code is displayed and can be copied or shared.
• Pending requests show athlete name and timestamp of request.
• Approving a request adds the athlete to the team and notifies them.
• Rejecting a request removes it from the list; athlete is notified.
FR-07: Create Post — Announcement
Description: The system shall allow the coach to create an announcement post containing
only text. The post shall appear as a card in the team feed visible to all approved team
athletes.
Rationale: Announcements allow coaches to broadcast messages.
Acceptance Criteria:
• Announcement requires text content; no date or time is needed.
• Post appears in the team feed in reverse chronological order.
• Athletes can view announcements in their team feed.
AthletiTrack-SRS – LCB-Tech – Page 26
FR-08: Create Post — One-Time Training Session
Description: The system shall allow the coach to create a one-time training session by
specifying: date, start time, end time, optional description, and optional skill level visibility
filter (All, Beginner, Intermediate, Expert). The system shall generate a training card
displaying the day-of-week initials with the scheduled day in green and all other days in red.
Rationale: One-time sessions are used for specific training events and pre-competition
intensification.
Acceptance Criteria:
• Date, start time, and end time are required.
• Description and skill level filter are optional.
• Training card appears in team feed with colored day initials (green #4CAF50, red
#F44336).
• If skill level filter is set, only athletes with matching tags see the card.
• Card is tappable to open a detail modal.
FR-09: Create Post — Weekly Training Schedule
Description: The system shall allow the coach to create a recurring weekly schedule by
selecting days of the week (Monday through Sunday) and a daily time range (start and end
time). An optional description and skill level visibility filter may be set. If a weekly schedule
already exists for the team, the system shall prompt for overwrite confirmation. The new
schedule replaces the previous default and appears as a persistent card at the top of the team
feed.
Rationale: A recurring schedule eliminates repetitive manual entry.
Acceptance Criteria:
• At least one day of the week must be selected.
• Time range (start and end) is required.
• If a weekly schedule already exists, an overwrite confirmation dialog is shown.
• Weekly schedule card appears pinned at the top of the team feed.
• Schedule repeats indefinitely until overwritten or deleted.
• Coach can delete the weekly schedule at any time.
AthletiTrack-SRS – LCB-Tech – Page 27
FR-10: Training Card Modal and Details
Description: Tapping a training card shall open a modal displaying: session type label
(Training Schedule or Weekly Training Schedule), time in large font, description (if any), and
the row of day initials (M T W T F S S) with scheduled days in green and unscheduled days
in red. The coach shall have options to edit or delete the session from this modal.
Rationale: The modal provides a focused view of session details.
Acceptance Criteria:
• Modal opening animation finishes within 300 milliseconds.
• Time font size is at least 1.5 times larger than body text (minimum 24 sp on mobile).
• Day initials are color-coded: green for scheduled, red for unscheduled.
• Coach sees Edit and Delete options; athlete sees interaction options (proof upload,
comment, reminder).
• Deleting a session removes it from the feed for all team members.
FR-11: Athlete Dashboard and Team Joining
Description: The system shall provide athletes with a dashboard mirroring the coach's UI but
with a "+" button that triggers a "Join Team" dialog. The athlete enters a team code provided
by their coach. On valid code entry, the system shall send a join request to the coach. After
coach approval, the team card shall appear on the athlete's dashboard with access to the team
feed.
Rationale: Athletes need a simple, code-based method to join teams.
Acceptance Criteria:
• "+" button opens a text field for team code entry.
• An invalid team code produces a descriptive error within 1 second: “Invalid team
code. Please check and try again.”
• Valid code sends a join request to the coach with the athlete's name.
• After approval, team appears on athlete's dashboard.
• Athlete cannot join the same team more than once.
AthletiTrack-SRS – LCB-Tech – Page 28
FR-12: Athlete Team Feed and Training Interaction
Description: Inside an athlete's team page, the system shall display the feed with the weekly
schedule card (if any) pinned at the top, followed by announcements and one-time training
cards in reverse chronological order. Athletes shall be able to tap a one-time training card to:
view full details, comment, upload proof of training, mark the session as done, or submit an
excuse.
Rationale: This interaction flow mirrors Google Classroom's assignment submission.
Acceptance Criteria:
• Weekly schedule card appears first in the feed if one exists.
• Announcements and one-time sessions follow in reverse chronological order.
• Tapping a one-time session opens a modal with interaction options.
• Athlete can upload proof (image, video, or document) with an optional text message.
• When an unsupported file format is selected, the system blocks the upload before any
network transfer and displays an error within 500 milliseconds listing allowed
formats.
• Athlete can submit an excuse with an attached document and explanation.
• Feed respects skill level visibility filters.
FR-13: Proof Upload with Automatic Date and Time Stamp
Description: The system shall allow athletes to upload proof of training from their device
storage or camera. The system shall automatically record the date and time of upload and
associate it with the specific training session and athlete. Supported formats: JPEG, PNG,
MP4, PDF, DOC, DOCX. The upload shall display a progress indicator.
Rationale: The auto-stamp removes any ambiguity about when proof was captured.
Acceptance Criteria:
• Athlete can select files from device gallery or capture new photos/videos in-app.
• System records and displays the exact upload timestamp.
• Upload progress is shown with a visual indicator (percentage or progress bar).
• Proof is linked to the correct training session and athlete in Supabase.
• File size limit of 10MB per upload; images are compressed for faster transfer.
• Supported formats are validated before upload begins.
AthletiTrack-SRS – LCB-Tech – Page 29
FR-14: Dynamic Attendance Table
Description: For each team, the system shall provide an Attendance tab accessible by the
coach. The table shall display athlete names as rows and training sessions as columns. Onetime training sessions shall auto-populate as columns upon creation. Weekly training sessions
shall appear as columns only after the scheduled date has passed. Each cell shall be colorcoded: green if the athlete submitted proof and the coach approved it, red if no proof was
submitted or the proof was rejected.
Rationale: Color coding enables instant visual assessment of compliance.
Acceptance Criteria:
• Table headers show session date and time for one-time sessions.
• Weekly sessions generate columns automatically after the session date passes.
• Future sessions are not displayed as columns.
• Green cell = approved proof present.
• Red cell = no proof or rejected proof.
• Table scrolls horizontally when many sessions exist.
• Coach can tap any cell to view details.
FR-15: Coach Approval and Rejection of Proof
Description: The system shall allow the coach to tap a cell in the attendance table to view the
submitted proof. The coach shall then be able to tap Approve or Reject. If rejecting, the coach
may enter an optional note explaining the reason. Approved cells turn permanently green;
rejected cells remain red.
Rationale: The approval mechanism gives coaches final verification authority.
Acceptance Criteria:
• Tapping a green or red cell opens the proof detail view.
• Coach sees the uploaded file, athlete message, and timestamp.
• Approve action turns cell permanently green.
• Reject action with optional note keeps cell red.
• Athlete sees the updated status in their training card view.
AthletiTrack-SRS – LCB-Tech – Page 30
FR-16: Export Attendance to Excel
Description: The system shall provide an "Export to Excel" button on the attendance page.
Tapping this button shall generate a properly formatted .xlsx file containing all athlete names,
session columns with dates, and color-coded compliance statuses. The file shall download
directly to the coach's device.
Rationale: Excel is the standard for institutional reporting.
Acceptance Criteria:
• Export button is visible on the attendance page.
• Generated .xlsx file matches the current table state on screen.
• All athlete names, session dates, and statuses are included.
• File downloads immediately with a descriptive filename including team name and
date.
• The .xlsx file opens without errors in Microsoft Excel 2016, Google Sheets, and
LibreOffice Calc. File size does not exceed 10 MB for a team with 100 athletes and
500 session columns.
FR-17: Calendar View for Coaches
Description: The system shall provide a calendar view accessible from the coach dashboard.
The calendar shall display all scheduled training sessions (one-time and weekly recurring
days) as colored indicators on their respective dates. Tapping a date shall list all sessions
scheduled for that day.
Rationale: The calendar prevents scheduling conflicts.
Acceptance Criteria:
• Calendar displays all teams' sessions by default with color coding per team.
• One-time sessions appear on their specific dates.
• Weekly recurring sessions appear on all matching future dates.
• Tapping a date shows a list of sessions with team name, time, and type.
• Coach can filter the calendar by team.
FR-18: Training Reminders for Athletes
Description: The system shall allow athletes to set a 5-minute reminder on any one-time
training session. The system shall trigger a local device notification at the set time displaying
AthletiTrack-SRS – LCB-Tech – Page 31
the session details. For weekly schedules, reminders shall trigger before each scheduled
occurrence.
Rationale: 100% of survey respondents said reminders would help consistency.
Acceptance Criteria:
• Reminder toggle is available on each one-time training card.
• Notification triggers within a ±30-second window of the scheduled 5-minute presession reminder.
• Notification displays session name, time, and team.
• Works on Android via local notification plugin; the notification is delivered even if
the app is in the background.
• Web version uses browser notification API where supported.
FR-19: Offline Data Caching
Description: The system shall cache previously loaded team feed content, training cards, and
announcements on the device. When the device loses internet connectivity, the cached data
shall remain viewable. A visible offline indicator shall be displayed at the top of the screen
within 2 seconds of connectivity loss. New proof uploads, post creation, and data
synchronization require an active internet connection.
Rationale: Training venues do not always have reliable connectivity.
Acceptance Criteria:
• Dashboard, team feed, and training cards are cached after first load.
• Offline banner is displayed prominently within 2 seconds of connectivity loss.
• Cached content is fully readable without internet for at least 24 hours without a sync.
• Upload and post actions are disabled with a clear message when offline.
• Cache is refreshed automatically when connectivity is restored.
FR-20: Skill Level Management
Description: The system shall allow the coach to assign a skill level tag (Beginner,
Intermediate, or Expert) to each athlete within a team. When creating a training post, the
coach may set a visibility filter to target specific skill levels. Athletes shall only see posts
relevant to their assigned skill level in their feed. The coach may update an athlete's skill
level at any time.
AthletiTrack-SRS – LCB-Tech – Page 32
Rationale: Coaches need to assign different routines to different skill levels.
Acceptance Criteria:
• Skill level is assigned per athlete per team (not globally).
• Default skill level for new athletes is Intermediate.
• Training post visibility filter defaults to "All" if no filter is set.
• Athletes only see posts matching their skill level or posts set to "All."
• Coach can change an athlete's skill level from the team member list.
AthletiTrack-SRS – LCB-Tech – Page 33
5. FUNCTIONAL REQUIREMENTS
5.1 Attendance and Recurring Schedule Implementation Logic
The attendance table’s dynamic behaviour relies on a clear separation between one-time
sessions and recurring weekly schedules. The following describes the underlying logic to
illustrate how the system automatically populates columns and maintains accuracy.
Recurring event expansion. A weekly schedule is stored in the posts table with type =
'weekly' and a schedule_data JSON field containing days_of_week (e.g., [1,3,5] for Monday,
Wednesday, Friday) and a daily time_range. The system does not pre-generate all future
sessions. Instead, when the coach or athlete views the attendance table or team feed, the
application calculates the next occurrence for each day of the week from the schedule’s
creation date onward. To limit overhead, it expands only the next 90 days of occurrences for
display. For attendance purposes, a session occurrence record is dynamically generated in the
attendance_records table on the day after the scheduled date, triggered by a scheduled job (or
a lazy evaluation when the attendance table is first accessed). This ensures that a column
appears for Tuesday’s training only on Wednesday, preventing empty future columns.
Attendance synchronisation. When a one-time session is created, the system immediately
inserts a row in attendance_records for every active team member, with status = 'absent' by
default. As athletes submit proof, the training_proof record links to that session, and the
attendance row is updated to 'present' upon coach approval. For weekly occurrences, a nightly
cron job (or an on-demand function triggered by the first coach access after midnight)
identifies all weekly schedules whose scheduled days match the previous calendar date. It
then creates the corresponding attendance_records for all team athletes, mirroring the same
default-absent logic. This batch processing avoids performance hits during peak usage.
Dynamic column generation. When the coach opens the attendance table, the frontend
requests the list of unique post_id and session_date pairs from the attendance_records table
for the team, ordered chronologically. The PHP API returns a list of column headers (date
and time label). The frontend constructs the table matrix by querying all attendance records
for that team, mapped by athlete ID and session. This design allows an arbitrarily growing
number of sessions without hard-coded column limits; horizontal scrolling accommodates the
width.
AthletiTrack-SRS – LCB-Tech – Page 34
6. NON-FUNCTIONAL REQUIREMENTS
6.1 Performance
The system shall load the coach dashboard and team feed within 3 seconds on a standard 4G
mobile connection. OTP emails shall be delivered within 30 seconds under normal SMTP
conditions, with a 99th percentile delivery time ≤60 seconds. Image uploads for training
proof shall be compressed to a maximum of 2MB before transfer. The attendance table shall
render within 5 seconds for teams with up to 50 athletes and 100 recorded sessions. The 95th
percentile API response time for dashboard loading shall be ≤3 seconds measured over 1000
requests at 200 concurrent users.
6.2 Security
The system shall implement a multi-layered security architecture to protect user data,
maintain service integrity, and prevent unauthorised access.
Password hashing and storage. All user passwords are hashed using bcrypt with a cost factor
of at least 12 before storage in Supabase. Plaintext passwords are never logged, transmitted,
or stored.
OTP and authentication. One-time passwords are 6-digit numeric codes valid for 5 minutes.
After three consecutive invalid attempts, the account is locked from further OTP requests for
10 minutes (brute-force protection). OTPs are stored hashed and invalidated upon successful
verification.
Session management. Upon login, the PHP backend issues a cryptographically signed JWT or
random session token stored in an HttpOnly, Secure, SameSite=Strict cookie. The token
expires after 24 hours of inactivity. On logout, the token is invalidated server-side.
Brute-force protection. The login endpoint is rate-limited: maximum 5 failed attempts per IP
address within 15 minutes, after which further attempts are blocked for 15 minutes. Accountspecific lockout is implemented after 10 failed attempts, requiring email-assisted recovery.
CSRF mitigation. The PHP API uses the SameSite cookie attribute and, when feasible, a
double-submit cookie pattern. State-changing endpoints (POST, PUT, DELETE) require a
CSRF token in the request header, validated against the server session.
AthletiTrack-SRS – LCB-Tech – Page 35
Secure cookie handling. All session and authentication cookies are set with HttpOnly, Secure,
and SameSite=Strict attributes. In the Flutter web build, cookies are managed via platformspecific HTTP clients with these flags enforced.
Role-based access control. Every PHP API endpoint checks the authenticated user’s role
(coach or athlete) before executing. Cross-team data access is prevented by filtering all
queries with the user’s authorised team IDs.
Audit logs. Critical actions are logged in a dedicated audit_logs table: registration,
login/logout, team creation, proof approval/rejection, role changes, and exports. Each entry
records user ID, action, timestamp, and IP address. Audit logs are immutable from the
application layer.
File upload sanitisation. All uploaded files undergo server-side checks:
• MIME type validation: the declared MIME type is checked against a whitelist
(image/jpeg, image/png, video/mp4, application/pdf, application/msword,
application/vnd.openxmlformats-officedocument.wordprocessingml.document). The
file’s magic bytes are inspected to verify that actual content matches the declared
type, preventing MIME spoofing.
• Malware scanning: files are scanned using ClamAV (or equivalent) before storage.
Infected files are rejected; the event is logged.
• Size and format constraints: maximum 10 MB; unsupported extensions rejected.
Encrypted storage. Supabase PostgreSQL encrypts data at rest using AES-256. Supabase
Storage files are also encrypted at rest. All data in transit is protected by TLS 1.3 (HTTPS),
enforced via HSTS headers on the PHP server.
These controls collectively ensure confidentiality, integrity, and availability appropriate to the
sensitivity of training monitoring data.
6.3 Usability
The system shall be mobile-first in design, with tappable elements measuring a minimum of
44 by 44 pixels. Navigation shall follow patterns familiar to Google Classroom users. All
error messages shall use plain, descriptive language without technical codes, and each shall
be tagged with a numeric error code for logging. Color-coded attendance cells (green for
compliant, red for non-compliant) and day-of-week initials (green for scheduled, red for
unscheduled) shall provide at-a-glance status recognition. In usability testing with at least 5
AthletiTrack-SRS – LCB-Tech – Page 36
representative users, the task completion rate for “create a training session” shall be ≥90%,
and average time-on-task ≤120 seconds.
6.4 Reliability
The system shall not lose previously loaded data when the device loses internet connectivity.
All cached content shall remain accessible and readable offline for at least 24 hours without a
sync. A persistent offline indicator shall appear within 2 seconds of connectivity loss. The
system shall target a minimum uptime of 95% during expected usage hours (6:00 AM to
10:00 PM Philippine Standard Time), measured by a synthetic monitoring script. API
downtime shall not corrupt locally cached data.
6.5 Scalability
The system is designed to support an initial user base of up to 500 concurrent users and 50
active teams. The architectural choices and optimisation strategies provide a clear path to
handle this load without degradation.
Caching strategies. Frequently accessed, rarely changed data—such as team member lists and
weekly schedule definitions—will be cached in the PHP backend using an in-memory store.
On the Flutter client, local caching reduces API calls. Cache entries are invalidated when a
coach updates a schedule or approves a new member.
Load balancing. The PHP API will be deployed on Render.com with automatic horizontal
scaling. The architecture is stateless (session data stored in the database), allowing seamless
transition to paid tiers with more instances if demand grows.
API optimisation. Database queries use Supabase’s PostgREST API with careful use of
indexes and joins. Large queries, such as attendance-table generation for 500 sessions, are
paginated. The Excel export is generated asynchronously: the API enqueues a job, and the
result is stored temporarily for download, preventing request timeouts.
Queueing strategies. Long-running tasks—Excel generation, malware scanning, and future
push notification dispatch—are placed in a job queue (a simple database-backed queue in
Supabase, with a PHP worker process). This decouples heavy processing from the HTTP
request-response cycle, ensuring that API response times remain within the 3-second target
under load.
AthletiTrack-SRS – LCB-Tech – Page 37
Database scalability. Supabase PostgreSQL provides connection pooling and automatic read
replicas on higher tiers. The schema design uses appropriate indexes on foreign keys and
frequently queried columns, supporting efficient query execution for thousands of records per
team.
6.6 Maintainability
The system shall follow clean code principles with meaningful variable names, modular file
organization, and separation of UI and business logic in Flutter. The PHP backend shall use
separate route files organized by feature. All API endpoints shall be documented with inline
comments. The team shall use Git for version control with a clear branching strategy. The
Supabase schema shall be versioned using migration files.
6.7 Portability
The Flutter application shall run on Android 8.0 or later. The web application shall function
on any modern browser (Chrome, Firefox, Safari, Edge) without plugins. The PHP backend
shall be deployable on any hosting environment supporting PHP 8.0+ and Composer.
Supabase is accessible from any internet-connected application via its standard API.
6.8 Compatibility
The web version shall be fully responsive, rendering correctly on screen widths from 375
pixels to 1920 pixels. Supported file upload formats: JPEG, PNG, MP4, PDF, DOC, DOCX,
with a default maximum of 10MB per file. The exported Excel file shall be compatible with
Microsoft Excel 2016+, Google Sheets, and LibreOffice Calc. The app shall coexist with
other installed apps without conflict on Android.
6.9 Offline Data Synchronization
Offline support in AthletiTrack relies on a structured local caching and queueing system to
ensure data consistency when connectivity is intermittent.
Cache management and staleness. When the Flutter client retrieves team feeds and training
cards, it stores the data locally with a server-provided last_modified timestamp. On
subsequent loads, the client sends the If-Modified-Since header, and the server returns only
changed data. If the server is unreachable, the cached version is displayed with a prominent
“Offline – data from [timestamp]” banner. Cache entries are considered stale after 24 hours
without a successful sync; a background refresh is attempted upon reconnection.
AthletiTrack-SRS – LCB-Tech – Page 38
Offline write queue. When the athlete performs actions that modify state (upload proof,
submit excuse, mark done) while offline, the action is serialised as a JSON job and stored in a
local offline_queue table. Each job includes a unique client-generated ID, the target API
endpoint, and the payload. The queue respects creation order and persists across app restarts.
Conflict handling and synchronisation. Upon reconnection, the queue processor iterates
through pending jobs sequentially. For each job, the PHP endpoint checks idempotency using
the client-generated ID: if the server has already processed that ID (via a unique constraint on
a sync_tracking table), the action is skipped to prevent duplicates. If a conflict occurs (e.g.,
athlete submits proof for a session the coach has deleted), the server returns a 409 Conflict
with an explanatory message, and the job is moved to a failed queue for manual review.
Cache invalidation. After a successful sync, the client clears the local cache for any entities
modified by the server. The API response includes a list of changed resource IDs and their
new last_modified timestamps. The client then fetches fresh versions and updates the local
database, minimising full re-downloads while ensuring users see the latest state.
This approach guarantees that offline usage never results in permanently lost data and that
coaches see an accurate representation of athlete compliance once syncing completes.
AthletiTrack-SRS – LCB-Tech – Page 39
7. SYSTEM ARCHITECTURE
7.1 Architectural Pattern
AthletiTrack follows a Client-Server architecture with a Layered backend. The Flutter
frontend communicates with a PHP REST API, which uses the Supabase client for database
operations. Email functions are handled by PHP Mailer via SMTP.
• Presentation Layer: Flutter UI (Android/Web)
• Business Logic Layer: PHP API endpoints (authentication, team management, post
CRUD, attendance queries)
• Data Layer: Supabase PostgreSQL (tables, storage buckets) accessed through
Supabase API
7.2 Technology Stack
Layer Technology Purpose
Frontend Flutter (Dart) Cross-platform UI for
Android APK and web
Backend PHP (vanilla, RESTful) Authentication, business
logic, email sending
Email PHP Mailer + Gmail SMTP OTP and notification emails
Database Supabase (PostgreSQL) Persistent data, file storage
Storage Supabase Storage Uploaded proof files
(images, videos, docs)
Hosting (Backend) Render.com (or similar) PHP API hosting
Hosting (Web) Render.com / Flutter build Static web app hosting
Version Control Git & GitHub Source code management
AthletiTrack-SRS – LCB-Tech – Page 40
7.3 Architecture Diagram
AthletiTrack-SRS – LCB-Tech – Page 41
8. INTERFACE REQUIREMENTS
8.1 User Interface
• Coach Dashboard: FAB (“+”) bottom-right; horizontally scrollable team cards;
slide-out menu (left) with profile, about, logout.
• Team Page: Team name header; buttons for team code, pending requests, create post.
• Training Modal: Large time display, colored day initials (green/red), description.
• Attendance Tab: Table with sticky headers; color-coded cells; export button.
• Athlete Dashboard: Mirror of coach UI but “+” triggers join team dialog.
• Offline Indicator: Persistent banner at top when offline, appearing within 2 seconds
of connectivity loss.
• All interfaces follow material design guidelines.
8.2 Software Interface
• PHP Mailer API: Sends emails via Gmail SMTP (smtp.gmail.com, port 587, TLS).
• Supabase Client API: Flutter uses supabase_flutter package; PHP uses HTTP calls
or the official Supabase PHP library.
• Browser Local Storage: For caching user session and last-fetched data on web.
8.3 Hardware Interface
• No direct hardware interfaces. The system relies on standard device cameras and
storage for file uploads.
• Android devices must have camera and gallery access granted by user.
AthletiTrack-SRS – LCB-Tech – Page 42
9. DATA REQUIREMENTS
9.1 Database Overview
The Supabase PostgreSQL database contains the following primary tables:
Table Description Key Fields
users
All registered coaches
and athletes
id, full_name, email, password_hash, role,
created_at
teams Teams created by
coaches
id, coach_id, name, description, category,
logo_url, team_code, created_at
team_members Approved athletes in
teams id, team_id, user_id, skill_level, joined_at
join_requests Pending athlete join
requests id, team_id, user_id, status, created_at
posts Announcements and
training sessions
id, team_id, type
(announcement/one_time/weekly), title,
description, schedule_data (JSON),
skill_level_filter, created_at
training_proof Athlete-submitted proof
of training
id, post_id, user_id, file_url, file_type,
message, status
(pending/approved/rejected), coach_note,
submitted_at
attendance_records Auto-generated perathlete per-session rows
id, team_id, user_id, post_id, session_date,
status (present/absent/excused), proof_id
(nullable)
excuses
Athlete-submitted
excuse documents
id, user_id, post_id, file_url, explanation,
submitted_at
audit_logs Security and action logs id, user_id, action, ip_address, timestamp
9.2 Data Integrity Rules
• A user cannot join the same team more than once.
• A weekly schedule is unique per team (only one active).
AthletiTrack-SRS – LCB-Tech – Page 43
• Attendance records are generated automatically when a one-time session is created or
when a weekly session’s date passes.
• Foreign keys enforced via Supabase constraints.
• Passwords are never stored as plaintext.
9.3 Backup and Recovery
Supabase provides automatic daily backups of the database. The development team will
perform manual exports of critical tables before major releases. Athlete proof files stored in
Supabase Storage are replicated automatically.
AthletiTrack-SRS – LCB-Tech – Page 44
10. TESTING STRATEGY
This section defines the comprehensive testing approach for AthletiTrack. Each testing type
is described with its scope, objectives, and specific application to the system’s core features.
10.1 Unit Testing
Unit tests verify the smallest testable parts of the application in isolation. In the PHP
backend, every API endpoint function will be tested using PHPUnit. Tests cover:
authentication controllers (valid/invalid login, OTP verification, token generation), team
management (creation, team-code uniqueness, join-request processing), training schedule
logic (date validation, weekly recurrence expansion, skill-level visibility), attendance
generation (correct insertion and delayed column creation), and Excel export (formatting,
data completeness). In the Flutter frontend, unit tests validate individual widgets and statemanagement logic, including offline cache read/write, local notification scheduling, and form
validation.
10.2 Integration Testing
Integration tests validate the interaction between the Flutter client, PHP API, and Supabase.
Key scenarios include: end-to-end registration (Flutter form → PHP API → Supabase user
creation → email OTP → verification and session creation), proof upload flow (file picker →
upload endpoint → Supabase storage → training_proof insertion → attendance record
update), real-time team joining, and offline sync restoration (simulate connectivity loss,
queue actions, restore connection, and verify automatic API calls with conflict resolution).
Integration tests will be automated using Postman collections or a custom testing harness.
10.3 Security Testing
Security testing targets unauthorised access, data breaches, and common web vulnerabilities.
Specific tests include: OTP brute-force (rapid submissions; verify rate limiting and
cooldown), role-based access (attempt to access coach endpoints with an athlete token and
vice-versa; confirm 403 Forbidden), SQL injection and XSS (submit malicious payloads in
team names, announcements, and proof messages; verify input sanitisation), file upload abuse
(attempt executable files, oversized files, fake MIME types; confirm server-side MIME
validation, size limits, and virus scanning), and session hijacking (reuse a token from a
different IP/user-agent; verify secure cookie attributes and token invalidation on logout).
Penetration test results must show no critical or high-risk vulnerabilities (CVSS ≥7.0).
AthletiTrack-SRS – LCB-Tech – Page 45
10.4 Usability Testing
Usability testing evaluates how effectively coaches and athletes can perform core tasks. Test
participants will be recruited from the original survey respondents. Tasks include: register
and verify OTP, create a team and share code, join a team, create a one-time session and a
weekly schedule, submit proof and an excuse, review attendance and export to Excel. Metrics
collected: task completion rate, time-on-task, error frequency, and post-test System Usability
Scale (SUS) score. Success thresholds: ≥90% task completion rate, average time for trainingsession creation ≤120 seconds, SUS score above 68.
10.5 Stress and Performance Testing
Using Apache JMeter or k6, the following tests will be executed: gradual load increase from
1 to 500 concurrent virtual users accessing the dashboard, measuring API response time at
each level; sustained load of 200 concurrent users for 30 minutes, monitoring CPU, memory,
and database connection pool; file upload stress (10 simultaneous 10 MB proof uploads;
verify completion without timeout); and database query performance (attendance-table
generation for 100 athletes and 500 sessions; must complete under 5 seconds). Acceptance:
95th percentile API response time ≤3 seconds at 500 concurrent users, zero upload failures,
attendance table rendering within 5 seconds at maximum data load.
AthletiTrack-SRS – LCB-Tech – Page 46
11. ACCEPTANCE CRITERIA
The system shall be considered complete when:
• All 20 functional requirements (FR-01 to FR-20) are implemented, pass their
respective unit tests with a minimum of 80% code coverage, and pass integration
tests.
• All non-functional requirements in Section 6 are validated through performance and
security testing as described in Section 10. End-to-end execution of UC-01 through
UC-08 results in no unhandled exceptions or incorrect state transitions; all success
paths complete within 30 seconds from start to finish for a user on a 4G connection.
• User stories US-01 through US-12 meet the quantifiable acceptance criteria stated in
each FR.
• The complete workflow (coach creates team → athlete joins → coach posts training
→ athlete submits proof → coach reviews attendance → exports to Excel) completes
without manual intervention, and the export file opens without corruption in
Microsoft Excel 2016, Google Sheets, and LibreOffice Calc.
• Email OTP verification: 100% of OTP emails are delivered within 30 seconds under
normal SMTP conditions, and 95% within 60 seconds during peak load.
• The application is deployable as an APK (minimum Android 8.0) and a responsive
web app; APK installs successfully on a factory-reset device, and the web version
achieves a Lighthouse performance score of ≥75 on mobile.
• Offline caching: after a fresh sync, at least 95% of previously displayed feed content
is readable when the device is placed in airplane mode; the offline banner appears
within 2 seconds of connectivity loss.
• No high-severity bugs (defined as bugs that prevent a core user story from
completing) remain open at submission; medium-severity bugs are documented with
workarounds.
AthletiTrack-SRS – LCB-Tech – Page 47
12. APPENDICES
Appendix A — Use Case Diagram
AthletiTrack-SRS – LCB-Tech – Page 48
Appendix B — Entity-Relationship (ER) Diagram
The diagram below shows all database tables and their relationships, including all foreign key
connections. The database is hosted on Supabase (PostgreSQL).
AthletiTrack-SRS – LCB-Tech – Page 49
Table Description Key Fields
users
All registered coaches
and athletes
id, full_name, email, password_hash, role,
created_at
teams Teams created by
coaches
id, coach_id, name, description, category,
logo_url, team_code, created_at
team_members Approved athletes in
teams id, team_id, user_id, skill_level, joined_at
join_requests Pending athlete join
requests id, team_id, user_id, status, created_at
posts Announcements and
training sessions
id, team_id, type
(announcement/one_time/weekly), title,
description, schedule_data (JSON),
skill_level_filter, created_at
training_proof Athlete-submitted proof
of training
id, post_id, user_id, file_url, file_type,
message, status
(pending/approved/rejected), coach_note,
submitted_at
attendance_records Auto-generated perathlete per-session rows
id, team_id, user_id, post_id, session_date,
status (present/absent/excused), proof_id
(nullable)
excuses
Athlete-submitted
excuse documents
id, user_id, post_id, file_url, explanation,
submitted_at
audit_logs Security and action logs id, user_id, action, ip_address, timestamp
AthletiTrack-SRS – LCB-Tech – Page 50
Appendix C — System Architecture Diagram
Architecture Overview:
• Presentation Layer: Flutter application (Android APK and responsive web build).
Handles all user interface rendering, local caching, and notification triggers.
• Business Logic Layer: PHP REST API deployed on cloud hosting. Handles
authentication, team management, post CRUD operations, attendance queries, Excel
export generation, and email dispatch via PHP Mailer.
• Data Layer: Supabase PostgreSQL database for persistent storage and Supabase
Storage for uploaded proof files. All database access from PHP uses Supabase client
API.
AthletiTrack-SRS – LCB-Tech – Page 51
Communication Flow:
1. Flutter client sends HTTP requests to PHP API endpoints.
2. PHP API processes business logic, validates permissions, and interacts with
Supabase.
3. Supabase returns data; PHP formats response as JSON.
4. Flutter client updates UI and caches data locally.
5. Email notifications (OTP) are sent via PHP Mailer through Gmail SMTP.
Appendix D — Requirements Traceability Matrix
The following matrix maps each functional requirement to its corresponding use cases and
user stories.
Req. ID Requirement Name Related UC(s) Related US(es)
FR-01 Coach Registration with Email OTP UC-01 –
FR-02 Athlete Registration with Email OTP – –
FR-03 Role-Based Login and Session
Management UC-01 –
FR-04 Coach Dashboard with Slide-Out
Menu UC-02 US-07
FR-05 Team Creation and Team Code
Generation UC-02 US-02, US-07
FR-06 Team Page and Join Request
Management UC-04 US-08
FR-07 Create Post — Announcement UC-03 –
AthletiTrack-SRS – LCB-Tech – Page 52
FR-08 Create Post — One-Time Training
Session UC-03 US-02, US-09,
US-12
FR-09 Create Post — Weekly Training
Schedule UC-03 US-02, US-09
FR-10 Training Card Modal and Details UC-03 –
FR-11 Athlete Dashboard and Team Joining UC-04 US-08
FR-12 Athlete Team Feed and Training
Interaction UC-05 US-01, US-05
FR-13 Proof Upload with Auto Date/Time
Stamp UC-05 US-01, US-04
FR-14 Dynamic Attendance Table UC-06 US-03
FR-15 Coach Approval and Rejection of
Proof UC-06 US-04
FR-16 Export Attendance to Excel UC-08 US-11
FR-17 Calendar View for Coaches UC-07 US-07, US-09
FR-18 Training Reminders for Athletes – US-06
FR-19 Offline Data Caching – US-10
FR-20 Skill Level Management – US-02, US-12