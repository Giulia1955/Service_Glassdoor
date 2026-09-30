# Glassdoor View Pages Design

## Goal

Adapt the Flutter view layer to the current `glassdoor_service.dart` API contract. The app must provide complete pages for company search, company reviews, general job search, company jobs, and GIF search while preserving the current dark visual style.

## Scope

The implementation covers the five existing view files:

- `company_search_page.dart`
- `company_review_page.dart`
- `company_job_search.dart`
- `companies_jobs_page.dart`
- `home_page.dart` integration

The service remains the source of truth for requests and validation. The pages must use these methods without changing endpoint contracts:

- `searchCompany`
- `reviewCompany`
- `jobSearch`
- `companyjobs`

## Architecture

Each feature page owns its form fields and request state. Small private widgets or helpers may be shared where they improve consistency, but no state-management package or new runtime dependency is needed.

`HomePage` remains the navigation entry point and exposes five destinations:

1. Company search
2. Company reviews
3. Job search
4. Jobs by company

The pages instantiate and call the current service, use `Validador` through the service contract, and do not expose API keys in the UI.

## Page behavior

### Company search

The page accepts a company name and submits it to `searchCompany`. Results are rendered as cards, showing available company name, location, rating, and company ID. Optional fields are omitted or replaced with neutral text.

### Company reviews

The page accepts a numeric company ID and submits it to `reviewCompany`. It renders available company summary data and a scrollable list of reviews. Missing review fields must not crash the page.

### General job search

The page collects:

- Job term
- Location
- Location type
- Minimum company rating
- Remote-only flag
- Easy-apply-only flag

It submits these values to `jobSearch` and renders available title, company, location, salary, description, and job link information for each result.

### Jobs by company

The page collects:

- Company ID
- Job function
- Maximum age in days
- Location type
- Sort order

It submits these values to `companyjobs` and renders the returned job cards.

## UI states and errors

Every page provides:

- An initial instruction before the first search
- A loading indicator during the request
- A successful result view
- A feature-specific empty-state message
- An explicit error message based on the thrown service exception

The existing dark theme is preserved. Lists must be scrollable, and external job links may be rendered as links only when a valid URL is present. The views must tolerate absent or differently shaped optional response fields without throwing during rendering.

## Compatibility fixes

The current views contain references to the previous API implementation, including old service class and method names and an import for a missing details page. These references will be replaced with the current service class and methods, and navigation will only reference files present in the project.

No API endpoint, authentication behavior, or unrelated project configuration will be changed as part of the view adaptation.

## Testing and validation

The legacy counter smoke test will be replaced with widget coverage for:

- App startup and the `Glassdoor Service` home title
- Presence of all five home navigation options

Validation commands:

```bash
flutter analyze
flutter test
```

The widget tests will not require live API credentials or network responses. Network-specific behavior remains represented by the explicit loading, empty, and error rendering branches in each page.
