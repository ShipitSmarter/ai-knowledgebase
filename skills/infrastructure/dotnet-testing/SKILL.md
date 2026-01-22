# Dotnet Testing Skill

Build and run .NET tests from ShipitSmarter microservice repositories.

## .NET SDK Location

The .NET SDK is installed at a custom location and may not be in the system PATH:

```bash
/home/bram/.dotnet/dotnet
```

Always use this full path for all dotnet commands.

## Building Solutions

```bash
# Build entire solution (run from repo root, e.g., /shipping or /rates)
/home/bram/.dotnet/dotnet build

# Build specific project
/home/bram/.dotnet/dotnet build src/Shipping.Api

# Build with minimal output
/home/bram/.dotnet/dotnet build -verbosity:quiet

# Build with warnings as errors (CI mode)
/home/bram/.dotnet/dotnet build -warnaserror
```

## Running Tests

### Run All Tests

```bash
# Run all tests in the test project
/home/bram/.dotnet/dotnet test test/Shipping.Tests
/home/bram/.dotnet/dotnet test test/Rates.Tests
```

### Filter Tests by Name

```bash
# Run test by exact method name
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "WhenGetList_ReturnsUnclosedInvoicesByCarrier"

# Run tests matching a pattern (partial match)
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "GivenGetInvoiceList"

# Run tests by class name
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "FullyQualifiedName~GivenGetInvoiceList"

# Run tests matching multiple patterns
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "Name~Test1|Name~Test2"
```

### Verbose Output

```bash
# Show detailed test output
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "TestName" --verbosity normal

# Show all console output from tests
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "TestName" --verbosity normal 2>&1

# Show diagnostic output
/home/bram/.dotnet/dotnet test test/Shipping.Tests --verbosity detailed
```

### Run Specific Test Categories

```bash
# Run only unit tests (if categorized with traits)
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "Category=Unit"

# Run only integration tests
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "Category=Integration"
```

## Common Repository Paths

| Repository | Test Project Path |
|------------|-------------------|
| shipping | `test/Shipping.Tests` |
| rates | `test/Rates.Tests` |

## Test Project Structure

```
test/Shipping.Tests/
├── Helpers/
│   ├── IntegrationTestBase.cs    # Base class for integration tests
│   ├── UnitTestBase.cs           # Base class with test data builders
│   └── CustomWebApplicationFactory.cs
├── IntegrationTests/
│   └── v4/
│       └── Invoices/
│           └── GivenGetInvoiceList.cs
└── UnitTests/
    └── ...
```

## Troubleshooting

### SDK Not Found

If you get "dotnet not found" or SDK version errors:

```bash
# Verify SDK is available
/home/bram/.dotnet/dotnet --list-sdks

# Check current version
/home/bram/.dotnet/dotnet --version
```

### Build Errors Before Testing

Always build before running tests to get clearer error messages:

```bash
/home/bram/.dotnet/dotnet build && /home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "TestName"
```

### Test Discovery Issues

If tests aren't being discovered:

```bash
# List all discovered tests
/home/bram/.dotnet/dotnet test test/Shipping.Tests --list-tests

# List tests matching a filter
/home/bram/.dotnet/dotnet test test/Shipping.Tests --filter "GivenGetInvoiceList" --list-tests
```

## Integration Test Requirements

Integration tests typically require:
- MongoDB running (usually via Docker or testcontainers)
- No external API dependencies (mocked via `HttpMessageHandler`)

The test infrastructure handles these automatically through `CustomWebApplicationFactory` and `MongoDbFixture`.
