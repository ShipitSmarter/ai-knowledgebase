# AI Tools for Analysts & Integration Specialists

**Get AI help with carrier integrations, data analysis, and troubleshooting at ShipitSmarter.**

This guide covers the AI tools most useful for integration specialists, customer success analysts, and anyone working with carrier configurations.

---

## Quick Setup

Run this in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

Then restart your terminal. Done!

---

## Your Main Tools

### Research

The `/research` command helps you find information and document it with sources.

```
/research DHL Express API rate limiting policies

/research best practices for SFTP file polling intervals

/research carrier tracking status code mappings
```

This creates a document in `research/` with:
- Summary of findings
- Key details
- Source links for verification

### Issue Reporting

When you find bugs or need features, use the `github-issue-creator` skill:

```
Create a bug report: PostNL tracking webhooks are duplicating events
when the carrier sends retries within 5 seconds

Create a feature request: Support for GLS FlexDelivery time windows
```

The AI writes clear issues that developers can act on.

---

## Common Tasks

### Analyzing Carrier Data

```
Here's a CSV of shipment data from last month. 
What are the most common delivery failure reasons by carrier?

Compare the delivery time distributions between DPD and DHL for Dutch shipments
```

### Troubleshooting Integrations

```
A customer says their UPS shipments aren't getting tracking updates.
Here's the last webhook we received: [paste JSON]
What might be wrong?

The Stitch mapping for FedEx is returning null for deliveryDate.
Here's the carrier response: [paste]
```

### Understanding Carrier Documentation

```
Here's the carrier's API documentation for their tracking endpoint: [paste or link]
Summarize the key fields we need to map

What authentication method does this carrier require?
```

### Writing Integration Specs

```
We need to integrate a new carrier: Budbee.
Create a specification document covering:
- API endpoints we need
- Data mapping to our standard fields
- Webhook handling requirements
- Error scenarios to handle
```

---

## Workflow: New Carrier Integration

### 1. Research the Carrier

```
/research Budbee API documentation and integration requirements
```

### 2. Create the Specification

```
Based on the research, create an integration specification for Budbee
including API mapping and webhook handling
```

### 3. Create the Issue

```
Create an issue for: Add Budbee carrier integration

Link to the spec document in the issue.
```

### 4. Support During Development

As engineers work on it, you can help answer questions:

```
The engineer asks: What should we do when Budbee returns status "PICKUP_FAILED"?
Based on the carrier docs, map this to our standard statuses.
```

---

## Workflow: Troubleshooting

### 1. Gather Information

Collect relevant data:
- Error messages
- Request/response logs
- Timestamps
- Affected shipments/consignments

### 2. Analyze with AI

```
Here's a tracking webhook that's not being processed correctly:
[paste webhook payload]

And here's the error from the logs:
[paste error]

What's likely going wrong?
```

### 3. Document the Finding

```
Create a bug report based on this analysis
```

### 4. Provide Context for Fix

```
The root cause seems to be X. 
What additional context should I add to the issue to help the developer fix it?
```

---

## Workflow: Customer Data Analysis

### 1. Export the Data

Get relevant data from the system (shipments, consignments, events, etc.)

### 2. Ask Questions

```
Analyze this shipment data and tell me:
- What percentage are delivered on time by carrier?
- What's the average time from label creation to first scan?
- Which carriers have the most "address unknown" failures?

Here's the data: [paste CSV or describe the file]
```

### 3. Create Actionable Insights

```
Based on this analysis, what recommendations should I make to the customer
for improving their delivery success rate?
```

---

## Tips for Better Results

### Provide Context

```
Good: "This is a webhook from PostNL for Dutch domestic parcels. 
       The customer uses same-day delivery windows."
Bad: "This webhook isn't working"
```

### Paste Actual Data

The AI can analyze real payloads better than vague descriptions:

```
Good: [Paste the actual JSON/XML]
Bad: "The tracking event has wrong data"
```

### Ask for Explanations

```
"Explain why this mapping might be failing - I need to explain it to the customer"
```

### Request Specific Formats

```
"Summarize this in a table I can share with the customer"

"Create a checklist for verifying this integration is working"
```

---

## Useful Commands Reference

| Command | Use Case |
|---------|----------|
| `/research <topic>` | Find and document information with sources |
| `Create a bug report for...` | Report issues you've found |
| `Create a feature request for...` | Request new capabilities |
| `Analyze this data...` | Get insights from CSV/JSON data |
| `Troubleshoot this error...` | Debug integration issues |

---

## Example Prompts

### For Carrier Research
```
/research DPD Predict API - what delivery time slot formats do they support?
```

### For Data Analysis
```
I have delivery event data for the last 30 days.
Which carrier-country combinations have the highest delivery failure rate?
[paste or upload data]
```

### For Troubleshooting
```
A customer's TNT shipments show as "delivered" in TNT's system
but still show "in transit" in Viya. Here's a sample event:
[paste event]
What's the likely cause?
```

### For Documentation
```
Document the retry logic we should use for the GLS API,
given they return 429 errors during peak hours
```

---

## Getting Help

- **Setup issues?** Check `echo $OPENCODE_CONFIG_DIR` - should show a path
- **AI giving wrong answers?** Provide more context or correct it directly
- **Questions?** Ask in the team Slack
