# Issue Templates

Templates for different issue types at ShipitSmarter.

## Bug Report

```markdown
### report

**Description**
<Clear description of what's broken>

**Steps to Reproduce**
1. Go to <location>
2. Click on <element>
3. Observe <behavior>

**Expected Behavior**
<What should happen>

**Actual Behavior**
<What actually happens>

**Environment**
- URL: <if applicable>
- Browser: <if frontend issue>
- User/Tenant: <if relevant>

**Screenshots**
<Add screenshots if helpful>

**Additional Context**
<Any other relevant information>
```

## Feature Request (User Story Format)

```markdown
### User Story

**As a** <role/persona>,
**I want** <capability/feature>,
**So that** <benefit/value>.

### Background

<Context and motivation for this feature. Why is it needed? What problem does it solve?>

### Requirements

- [ ] <Requirement 1>
- [ ] <Requirement 2>
- [ ] <Requirement 3>

### Acceptance Criteria

- [ ] <Criterion 1 - how do we verify this works>
- [ ] <Criterion 2>
- [ ] <Criterion 3>

### Design / Mockups

<Link to Figma, screenshots, or description of UI if applicable>

### Technical Notes

<Any technical considerations, dependencies, or constraints>
```

## Papercut (Small UI Issue)

```markdown
### report

<Brief description of the UI issue>

**Location**: <Page/component where this occurs>

**Screenshot**
<Screenshot showing the issue>

**Suggested Improvement**
<How it should look/behave instead>
```

## Task (Technical Work)

```markdown
### Background

<Why is this work needed? What's the context?>

### Requirements

- [ ] <Requirement 1>
- [ ] <Requirement 2>
- [ ] <Requirement 3>

### Done Criteria

- [ ] <How do we know this is complete>
- [ ] <Verification step>

### Technical Notes

<Implementation details, dependencies, or considerations>
```

## Examples

### Bug Example

```markdown
### report

**Description**
Consignment reference link ignores /test prefix in playground mode, leading to 404 errors.

**Steps to Reproduce**
1. Create a shipment in Test/Playground mode
2. Open shipment at URL like: `https://tenant.viyatest.it/test/shipment/{id}`
3. Navigate to Overview section
4. Click on Consignment Reference link in Tracking block

**Expected Behavior**
Link should navigate to `/test/consignment/{id}` preserving the test prefix.

**Actual Behavior**
Link navigates to `/consignment/{id}` without test prefix, showing non-existing consignment.

**Environment**
- URL: https://pr-tenant-stitch-integrations-2270.test.viyatest.it/test/shipment/{id}

**Screenshots**
<screenshot>

**Additional Context**
Manually adding /test prefix resolves the issue, confirming this is a routing bug.
```

### Feature Example

```markdown
### User Story

**As a** logistics manager,
**I want** to see the ETA on the consignment page,
**So that** I can quickly check delivery estimates without navigating to the shipment.

### Background

Currently the requested/planned/actual delivery date is shown in the shipment tracking sidepanel, but not on the consignment page. Since most track & trace data comes in at the consignment level, users need this information there too.

### Requirements

- [ ] Display ETA in consignment tracking sidepanel
- [ ] Show same date fields as shipment (requested/planned/actual)
- [ ] Update when new tracking events arrive

### Acceptance Criteria

- [ ] ETA visible on consignment detail page
- [ ] Dates match what's shown on parent shipment
- [ ] Works for all carrier integrations

### Design / Mockups

Similar to existing shipment sidepanel:
<screenshot reference>
```

### Papercut Example

```markdown
### report

Carrier profile cards have inconsistent widths, creating misalignment.

**Location**: Carrier settings page, profile cards section

**Screenshot**
<screenshot showing misaligned cards>

**Suggested Improvement**
Card widths should be consistent, with each section (logo, name, details) having fixed widths.
```

### Task Example

```markdown
### Background

Legacy /v3 API endpoints are deprecated but still in the codebase. We need to verify no traffic remains before removing them.

### Requirements

- [ ] Check Grafana for traffic on /v3 endpoints (last 2 weeks)
- [ ] If no traffic, remove endpoints from shipping service
- [ ] Remove corresponding legacy pages from viya-app

### Done Criteria

- [ ] No /v3 endpoint traffic confirmed in logs
- [ ] Endpoints removed from shipping service
- [ ] Legacy pages removed from viya-app
- [ ] PR merged and deployed

### Technical Notes

Endpoints to check:
- `/v3/consignments/{id}/...`
- `/v3/pickups/{id}/...`

Related pages in viya-app:
- `/consignment/order-request`
- `/consignments/tracking`
```
