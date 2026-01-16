---
title: Product Team Structure & Skills Matrix
date: 2026-01-13
status: draft
---

# Product Team Structure & Skills Matrix

## Executive Summary

This document maps our 14 product/engineering team members and proposes a clearer team structure that reduces overlap between product areas. The key insight is separating **Shipment** (what needs to move - sales order level) from **Consignment** (how it moves - carrier execution level).

## Current State

### Team Composition

| Role               | Count  | People                             |
| ------------------ | ------ | ---------------------------------- |
| Platform Engineers | 4      | Michael, Lennart, Jeffrey, Mila    |
| Product Engineers  | 5      | Sjoerd, Fatjon, Nick, Bram, Harris |
| Product Managers   | 2      | Roel, Wouter                       |
| Designers          | 3      | Dennis, Robin, Joel                |
| **Total**          | **14** |                                    |

**Key Overlaps Identified:**

1. Shipping vs Consignment - used interchangeably, now being separated
2. Shipping vs Visibility - both touch exception handling
3. Automation ownership - unclear who owns workflow automation

---

## People Skills Matrix

### Platform Team

| Name        | Role               | Primary Skills           | Secondary Skills     | Domain Knowledge   | Tenure          |
| ----------- | ------------------ | ------------------------ | -------------------- | ------------------ | --------------- |
| **Michael** | Senior Backend     | C#, Backend architecture | Kubernetes           | Platform-wide      | -               |
| **Lennart** | Senior Backend/SRE | C#, Kubernetes, DevOps   | Code quality         | Platform-wide      | -               |
| **Jeffrey** | Senior Backend     | C#, Shipping domain      | Platform maintenance | Shipping (deepest) | Longest serving |
| **Mila**    | Senior Frontend    | Vue, Storybook, Vitest   | Component library    | Frontend platform  | -               |

**Platform Team Focus**: Infrastructure, code quality, shared components, developer experience. Not assigned to product features directly but supports all teams.

### Product Engineers

| Name       | Role      | Primary Skills      | Secondary Skills     | Current Focus                  | Seniority | Notes                             |
| ---------- | --------- | ------------------- | -------------------- | ------------------------------ | --------- | --------------------------------- |
| **Sjoerd** | Senior PE | Full-stack          | Tracking, Visibility | Tracking, Visibility, Shipping | Senior    | Most versatile, can anchor a team |
| **Fatjon** | Medior PE | C#, Vue             | -                    | Consignments                   | Medior    | Deep in consignment domain        |
| **Nick**   | Medior PE | C#, Vue             | -                    | All over                       | Medior    | Needs focus assignment            |
| **Bram**   | Medior PE | Data, Analytics, AI | C#                   | Rates, Freight Settlement      | Medior    | Unique AI/data skillset           |
| **Harris** | PE        | C#                  | Learning             | New joiner                     | Junior    | Needs mentorship, learning curve  |

### Product Managers

| Name       | Style            | Background                                 | Strengths                                  | Best Paired With                       |
| ---------- | ---------------- | ------------------------------------------ | ------------------------------------------ | -------------------------------------- |
| **Roel**   | Detail-focused   | Domain expert                              | Practical, tactical, deep domain knowledge | Execution-heavy teams, complex domains |
| **Wouter** | Engineer-focused | Data engineering, Operations, Supply chain | Strategic, cross-functional, analytics     | New initiatives, cross-team alignment  |
| **Joey**   | ...              | New person starting in February            |                                            |                                        |

### Design

| Name       | Role      | Skills                 | Current Focus                                    | Tenure      | Notes                             |
| ---------- | --------- | ---------------------- | ------------------------------------------------ | ----------- | --------------------------------- |
| **Dennis** | Senior UX | Frontend + prototyping | All domains                                      | 1.5 years   | Fast prototyper, knows everything |
| **Robin**  | UX        | UX design              | Tracking, Freight Settlement, Ship/Consign split | 3 months    | Learning the domain               |
| **Joel**   | Visual PM | Visual design, Process | CSM support, PostHog, Releases                   | Just joined | Hybrid role with CSM team         |
