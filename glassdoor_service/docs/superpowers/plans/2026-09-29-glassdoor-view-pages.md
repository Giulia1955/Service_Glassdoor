# Glassdoor View Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the incomplete/legacy Flutter views with five working pages that consume the current `GlassodoorService` methods and display Glassdoor company, review, job, and GIF data.

**Architecture:** Keep each feature page responsible for its form and request state. Add a small shared view-helper file for safe response extraction and consistent dark-theme result/state widgets; do not add a state-management package or change the API service contract. Keep `HomePage` as the navigation entry point.

**Tech Stack:** Flutter/Dart 3.11+, Material widgets, existing `http` service, `flutter_test`, `flutter_lints`.

## Global Constraints

- Preserve the existing dark visual style.
- Use the current service methods exactly: `searchCompany`, `reviewCompany`, `jobSearch`, `companyjobs`, and `getGifs`.
- Do not expose or move API keys into the view layer.
- Do not add runtime dependencies.
- Every page must render initial, loading, success, empty, and explicit error states.
- Optional API fields must not crash rendering when absent or differently shaped.
- Lists must remain scrollable, and external links must only be shown when a valid URL is available.
- Do not change API endpoints, authentication behavior, or unrelated project configuration.
- Widget tests must not require live API credentials or network responses.

---

### Task 1: Establish shared view helpers and home navigation

**Files:**
- Create: `lib/view/view_helpers.dart`
- Modify: `lib/view/home_page.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Produces `String displayValue(dynamic value, {String fallback = 'Não informado'})`.
- Produces `Map<String, dynamic> asMap(dynamic value)`.
- Produces `List<Map<String, dynamic>> asMapList(dynamic value)`.
- Produces `Widget buildStateMessage(String message, {bool error = false})`.
- Produces `Widget buildResultCard({required String title, Map<String, String> fields = const {}, String? description, String? link})`.
- `HomePage` continues exposing the five destinations with labels `Buscar Empresa`, `Avaliações da Empresa`, `Buscar Vagas`, `Vagas por Empresa`, and `Buscar GIF`.

- [ ] **Step 1: Write the failing home widget test**

Replace the legacy counter test with:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:glassdoor_service/main.dart';

void main() {
  testWidgets('shows the Glassdoor home menu', (tester) async {
    await tester.pumpWidget(const GlassdoorApp());

    expect(find.text('Glassdoor Service'), findsOneWidget);
    expect(find.text('Buscar Empresa'), findsOneWidget);
    expect(find.text('Avaliações da Empresa'), findsOneWidget);
    expect(find.text('Buscar Vagas'), findsOneWidget);
    expect(find.text('Vagas por Empresa'), findsOneWidget);
    expect(find.text('Buscar GIF'), findsOneWidget);
  });
}
```

Run: `flutter test test/widget_test.dart`

Expected: FAIL because `GlassdoorApp` and the complete current home/test contract do not exist yet.

- [ ] **Step 2: Implement the shared helpers**

In `lib/view/view_helpers.dart`, implement safe extraction without casts that assume a response shape:

```dart
String displayValue(dynamic value, {String fallback = 'Não informado'}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

Map<String, dynamic> asMap(dynamic value) {
  return value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{};
}

List<Map<String, dynamic>> asMapList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}
```

Add `buildStateMessage` using white text on the existing black background, and `buildResultCard` using a `Card`/`ListTile` plus optional field rows, description, and a tappable URL only when `Uri.tryParse(link)` returns a valid HTTP(S) URI.

- [ ] **Step 3: Make app construction testable**

In `lib/main.dart`, add:

```dart
class GlassdoorApp extends StatelessWidget {
  const GlassdoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() => runApp(const GlassdoorApp());
```

Update `HomePage` to use `const` constructors where possible and remove the import for the missing `jobs_details_page.dart`. Keep the five existing navigation labels and routes.

- [ ] **Step 4: Run the focused test**

Run: `flutter test test/widget_test.dart`

Expected: PASS with one home-menu test.

- [ ] **Step 5: Commit the task**

```bash
git add lib/main.dart lib/view/home_page.dart lib/view/view_helpers.dart test/widget_test.dart
git commit -m "feat: establish Glassdoor view foundation"
```

### Task 2: Implement company search and review pages

**Files:**
- Modify: `lib/view/company_search_page.dart`
- Modify: `lib/view/company_review_page.dart`

**Interfaces:**
- Both pages instantiate `GlassodoorService`.
- `CompanySearchPage` calls `searchCompany(String search)`.
- `CompanyReviewPage` calls `reviewCompany(String companyId)`.
- Both pages use `Validador` indirectly through the service and keep a `Future<Map<String, dynamic>>?` request field so the initial state does not issue a network call.

- [ ] **Step 1: Add company-search form and request state**

Implement a `StatefulWidget` with a `TextEditingController`, a nullable `Future<Map<String, dynamic>> _future`, and a `_submit()` method:

```dart
void _submit() {
  final value = _controller.text.trim();
  if (value.isEmpty) {
    setState(() => _message = 'Digite o nome de uma empresa.');
    return;
  }
  setState(() {
    _message = null;
    _future = GlassodoorService().searchCompany(value);
  });
}
```

Use `TextField` with `onSubmitted: (_) => _submit()` and an explicit search button. Render the initial message when `_future == null`, then use `FutureBuilder` for loading/error/success branches.

- [ ] **Step 2: Render company-search responses safely**

Read the top-level response with `asMap(snapshot.data)`. Check `data` and common nested result keys through `asMapList`; if no list contains results, show `Nenhuma empresa encontrada.`. For each result, use `buildResultCard` with available `name`, `company_name`, `location`, `city`, `state`, `rating`, and `company_id` values.

- [ ] **Step 3: Add company-review form and response rendering**

Implement the same state pattern in `CompanyReviewPage`, using a numeric keyboard and `GlassodoorService().reviewCompany(id)`. For invalid/empty input, show `Digite um ID numérico de empresa.` before making a request.

Render an optional company summary card, then locate review entries from the response's `data` map using `asMapList`. Each review card should include available `headline`, `summary`, `pros`, `cons`, `job_title`, `review_date`, `rating`, and recommendation fields. Show `Nenhuma avaliação encontrada.` when no review list is present.

- [ ] **Step 4: Run analyzer and widget tests**

Run: `flutter analyze lib/view/company_search_page.dart lib/view/company_review_page.dart lib/view/view_helpers.dart`

Expected: no errors.

Run: `flutter test test/widget_test.dart`

Expected: PASS without any network call because the pages only request data after submission.

- [ ] **Step 5: Commit the task**

```bash
git add lib/view/company_search_page.dart lib/view/company_review_page.dart
git commit -m "feat: add company search and review pages"
```

### Task 3: Implement general job search page

**Files:**
- Modify: `lib/view/company_job_search.dart`

**Interfaces:**
- `JobSearchPage` calls:

```dart
GlassodoorService().jobSearch(
  String search,
  bool? remoteOnly,
  String? minCompanyRating,
  bool? easyApplyOnly,
  String? locationType,
  String location,
)
```

- [ ] **Step 1: Build the job-search form**

Add controllers for the job term and location. Add dropdowns for location type (`CITY`, `STATE`, `COUNTRY`) and minimum rating (`1` through `5`), plus `SwitchListTile` controls for remote-only and easy-apply-only. Keep nullable values for optional filters so an unselected filter becomes `null`, not an invented API value.

- [ ] **Step 2: Submit through the current service**

On submit, trim the two text fields, show a local validation message if either is empty, and set:

```dart
_future = GlassodoorService().jobSearch(
  term,
  remoteOnly,
  minCompanyRating,
  easyApplyOnly,
  locationType,
  location,
);
```

Do not construct a URL in the page and do not duplicate service validation.

- [ ] **Step 3: Render job results**

Read job entries from the response's nested `data` object using `asMapList`. For each job, use `buildResultCard` with `job_title`/`title`, `company_name`, `location`, `salary`, `job_type`, and `job_link`. Include a short description from `description` or `job_description` when available. Show `Nenhuma vaga encontrada.` for an empty result.

- [ ] **Step 4: Verify the page**

Run: `flutter analyze lib/view/company_job_search.dart`

Expected: no errors.

Run: `flutter test test/widget_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the task**

```bash
git add lib/view/company_job_search.dart
git commit -m "feat: add general job search page"
```

### Task 4: Implement company jobs and GIF search pages

**Files:**
- Modify: `lib/view/companies_jobs_page.dart`
- Modify: `lib/view/home_page.dart`
- Create: `lib/view/gif_search_page.dart`

**Interfaces:**
- `CompaniesJobsPage` calls:

```dart
GlassodoorService().companyjobs(
  String? jobFunction,
  int? maxAgeDays,
  String? locationType,
  String? sort,
  String companyId,
)
```

- `GifSearchPage` calls `GlassodoorService().getGifs(String search)`.

- [ ] **Step 1: Implement company-jobs filters**

Add a numeric company ID field, a job-function dropdown containing the service's accepted functions, a numeric maximum-age field, a location-type dropdown, and a sort dropdown. Convert the age text with `int.tryParse`; pass `null` for an empty optional filter. Submit with `GlassodoorService().companyjobs(...)`.

Render the response's job list with the same safe job-card mapping used by the general job page. Show an initial instruction, loading indicator, service error, and `Nenhuma vaga encontrada.` empty state.

- [ ] **Step 2: Implement GIF search**

Add `lib/view/gif_search_page.dart` with a text field and submit button. Call `getGifs` only after a non-empty term. From the returned map, safely read the first item in `data`, then the `images` map and a preferred URL in this order: `original.url`, `downsized_large.url`, `downsized.url`, `fixed_height.url`.

Render the image with `Image.network` using a loading builder and an `errorBuilder`; show `Nenhum GIF encontrado.` when no URL is available.

- [ ] **Step 3: Wire the GIF route and verify both pages**

Import `gif_search_page.dart` from `home_page.dart`, remove the old `GifSearchPage` import from `company_job_search.dart`, and keep the home route pointing to the single new GIF page class.

Run: `flutter analyze lib/view/companies_jobs_page.dart lib/view/gif_search_page.dart lib/view/home_page.dart`

Expected: no errors.

Run: `flutter test test/widget_test.dart`

Expected: PASS without network requests.

- [ ] **Step 4: Commit the task**

```bash
git add lib/view/companies_jobs_page.dart lib/view/gif_search_page.dart lib/view/home_page.dart
git commit -m "feat: add company jobs and GIF pages"
```

### Task 5: Run full validation and finish compatibility cleanup

**Files:**
- Modify: `lib/main.dart` or any page file only when required by analyzer/test output.
- Modify: `test/widget_test.dart` only when the final home contract changes.

**Interfaces:**
- All five pages remain reachable from `HomePage`.
- No view imports a missing file or references the old API class/method names.

- [ ] **Step 1: Search for stale API references**

Run:

```bash
rg -n "glassdoorApi|glassdoorValidation|buscaJob|parseJobResponse|jobs_details_page|MyApp" lib test
```

Expected: no stale references remain. The service's current class name `GlassodoorService` and methods are the only API symbols used by views.

- [ ] **Step 2: Run the full analyzer**

Run: `flutter analyze`

Expected: `No issues found!`

- [ ] **Step 3: Run the full test suite**

Run: `flutter test`

Expected: all tests pass without requiring `GLASSDOOR_KEY` or `GIPHY_KEY`.

- [ ] **Step 4: Inspect the final diff**

Run:

```bash
git --no-pager diff --check HEAD~4..HEAD
git status --short
```

Expected: no whitespace errors, only intended view/test changes remain, and pre-existing unrelated service changes are not reverted.

- [ ] **Step 5: Commit any final compatibility fix**

```bash
git add lib test
git commit -m "fix: align Glassdoor views with current service"
```
