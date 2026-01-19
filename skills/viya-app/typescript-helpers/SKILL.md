---
name: typescript-helpers
description: TypeScript patterns for types, interfaces, and type guards in viya-app. Use when defining types, working with generated API types, or creating type-safe utilities.
license: MIT
metadata:
  author: shipitsmarter
  version: "1.0"
---

# TypeScript Helpers Skill

Guidelines for TypeScript types, interfaces, and patterns in this project.

---

## Core principles

- **Strict typing required** - avoid `any`, prefer `unknown` with type guards
- **Use generated types** - import from `@/generated/*` for API responses
- **Type everything** - props, emits, functions, refs, and API responses

---

## Type vs Interface

### Use `interface` for:
- Object shapes that may be extended
- Props and emits definitions
- API response types (though prefer generated types)

```typescript
interface Props {
  title: string;
  items: Item[];
  readonly?: boolean;
}

interface Emits {
  (e: 'update', value: string): void;
  (e: 'close'): void;
}
```

### Use `type` for:
- Unions and intersections
- Mapped types
- Utility types
- Simple aliases

```typescript
type Status = 'pending' | 'active' | 'completed';
type ShipmentWithMeta = Shipment & { metadata: Record<string, unknown> };
type Nullable<T> = T | null;
```

---

## Generated API types

API types are auto-generated from OpenAPI specs. **Always use these instead of defining your own:**

```typescript
// Import from generated modules
import type { 
  Shipment, 
  ShipmentStatus,
  CreateShipmentRequest 
} from '@/generated/shipping';

import type { 
  Rate,
  RateRequest 
} from '@/generated/rates';

import type { 
  Address,
  AddressType 
} from '@/generated/address';
```

### Regenerating types

```bash
npm run generate-api
```

This pulls the latest OpenAPI specs and regenerates all types in `src/generated/`.

---

## Component typing

### Props

```typescript
interface Props {
  // Required prop
  shipmentId: string;
  
  // Optional prop
  readonly?: boolean;
  
  // Union type
  status?: 'pending' | 'active' | 'completed';
  
  // Complex type
  shipment?: Shipment;
  
  // Array type
  items: ShipmentItem[];
  
  // Function prop
  onSelect?: (item: ShipmentItem) => void;
}

const props = withDefaults(defineProps<Props>(), {
  readonly: false,
  status: 'pending',
});
```

### Emits

```typescript
interface Emits {
  (e: 'update:modelValue', value: string): void;
  (e: 'submit', data: FormData): void;
  (e: 'close'): void;
}

const emit = defineEmits<Emits>();

// Usage
emit('update:modelValue', 'new value');
emit('submit', formData);
emit('close');
```

### Refs

```typescript
// Simple ref
const loading = ref<boolean>(false);

// Nullable ref (common pattern)
const shipment = ref<Shipment | null>(null);

// Array ref
const items = ref<ShipmentItem[]>([]);

// Complex object
const formState = reactive<FormState>({
  name: '',
  email: '',
  valid: false,
});
```

### Computed

```typescript
const filteredItems = computed<ShipmentItem[]>(() => {
  return items.value.filter(item => item.active);
});

const isValid = computed<boolean>(() => {
  return formState.name.length > 0 && formState.email.includes('@');
});
```

---

## Type guards

Use type guards instead of `any` for runtime type checking:

### Basic type guards

```typescript
const isString = (value: unknown): value is string => {
  return typeof value === 'string';
};

const isNumber = (value: unknown): value is number => {
  return typeof value === 'number' && !isNaN(value);
};

const isArray = <T>(value: unknown): value is T[] => {
  return Array.isArray(value);
};
```

### Object type guards

```typescript
interface Shipment {
  id: string;
  status: string;
  carrier: string;
}

const isShipment = (value: unknown): value is Shipment => {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'status' in value &&
    'carrier' in value
  );
};

// Usage
const processData = (data: unknown) => {
  if (isShipment(data)) {
    // TypeScript knows data is Shipment here
    console.log(data.carrier);
  }
};
```

### Discriminated unions

```typescript
interface SuccessResponse {
  type: 'success';
  data: Shipment;
}

interface ErrorResponse {
  type: 'error';
  message: string;
}

type ApiResponse = SuccessResponse | ErrorResponse;

const handleResponse = (response: ApiResponse) => {
  if (response.type === 'success') {
    // TypeScript knows response.data exists
    return response.data;
  } else {
    // TypeScript knows response.message exists
    throw new Error(response.message);
  }
};
```

---

## Utility types

### Common built-in utility types

```typescript
// Make all properties optional
type PartialShipment = Partial<Shipment>;

// Make all properties required
type RequiredShipment = Required<Shipment>;

// Pick specific properties
type ShipmentSummary = Pick<Shipment, 'id' | 'status' | 'carrier'>;

// Omit specific properties
type ShipmentWithoutId = Omit<Shipment, 'id'>;

// Make all properties readonly
type ReadonlyShipment = Readonly<Shipment>;

// Record type for dictionaries
type ShipmentMap = Record<string, Shipment>;

// Extract return type of a function
type ServiceReturn = ReturnType<typeof shipmentService.getShipment>;

// Extract parameter types
type ServiceParams = Parameters<typeof shipmentService.getShipment>;
```

### Custom utility types

```typescript
// Nullable type
type Nullable<T> = T | null;

// Optional type (null or undefined)
type Optional<T> = T | null | undefined;

// Deep partial (all nested properties optional)
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// Make specific keys required
type RequireKeys<T, K extends keyof T> = T & Required<Pick<T, K>>;

// Example: Shipment with required id and carrier
type ShipmentWithRequiredFields = RequireKeys<Partial<Shipment>, 'id' | 'carrier'>;
```

---

## Function typing

### Basic function types

```typescript
// Arrow function with typed parameters and return
const formatPrice = (value: number): string => {
  return `$${value.toFixed(2)}`;
};

// Async function
const fetchShipment = async (id: string): Promise<Shipment> => {
  const response = await shipmentService.get(id);
  return response.data;
};

// Function with optional parameters
const greet = (name: string, greeting?: string): string => {
  return `${greeting ?? 'Hello'}, ${name}!`;
};
```

### Generic functions

```typescript
// Generic identity
const identity = <T>(value: T): T => value;

// Generic with constraint
const getProperty = <T, K extends keyof T>(obj: T, key: K): T[K] => {
  return obj[key];
};

// Generic array filter
const filterByStatus = <T extends { status: string }>(
  items: T[],
  status: string
): T[] => {
  return items.filter(item => item.status === status);
};
```

### Callback types

```typescript
// Define callback type
type OnSelectCallback = (item: ShipmentItem) => void;
type OnChangeCallback<T> = (value: T, oldValue: T) => void;

// Use in props
interface Props {
  onSelect?: OnSelectCallback;
  onChange?: OnChangeCallback<string>;
}
```

---

## Service typing

### Service class pattern

```typescript
import type { Shipment, CreateShipmentRequest } from '@/generated/shipping';
import { ApiResponse } from '@/services/types';

class ShipmentService {
  async get(id: string): Promise<ApiResponse<Shipment>> {
    // Implementation
  }

  async create(data: CreateShipmentRequest): Promise<ApiResponse<Shipment>> {
    // Implementation
  }

  async list(params?: ListParams): Promise<ApiResponse<Shipment[]>> {
    // Implementation
  }
}
```

### API response handling

```typescript
import type { CoreProblemDetails } from '@/services/clients';

interface ApiResponse<T> {
  isSuccess: () => boolean;
  data?: T;
  problem?: CoreProblemDetails;
}

// Usage
const result = await shipmentService.get(id);
if (result.isSuccess() && result.data) {
  shipment.value = result.data;
} else {
  error.value = result.problem?.detail ?? 'Unknown error';
}
```

---

## Const assertions

Use `as const` for literal types and readonly arrays:

```typescript
// Status literals
const STATUSES = ['pending', 'active', 'completed'] as const;
type Status = typeof STATUSES[number]; // 'pending' | 'active' | 'completed'

// Configuration object
const CONFIG = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,
} as const;

// Column definitions
const COLUMNS = [
  { key: 'name', label: 'Name', sortable: true },
  { key: 'status', label: 'Status', sortable: false },
] as const;
```

---

## Common patterns

### Nullable state

```typescript
// Loading state with nullable data
const shipment = ref<Shipment | null>(null);
const loading = ref(false);
const error = ref<string | null>(null);

const loadShipment = async (id: string) => {
  loading.value = true;
  error.value = null;
  
  try {
    const result = await shipmentService.get(id);
    if (result.isSuccess()) {
      shipment.value = result.data ?? null;
    } else {
      error.value = result.problem?.detail ?? 'Failed to load';
    }
  } finally {
    loading.value = false;
  }
};
```

### Form state

```typescript
interface FormState {
  name: string;
  email: string;
  address?: Address;
}

const formState = reactive<FormState>({
  name: '',
  email: '',
});

const isValid = computed(() => {
  return formState.name.length > 0 && formState.email.includes('@');
});
```

### Event handlers

```typescript
// Type event handlers explicitly
const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement;
  formState.name = target.value;
};

const handleSubmit = (event: SubmitEvent) => {
  event.preventDefault();
  // Submit logic
};
```

---

## What to avoid

### Never use `any`

```typescript
// ❌ Bad
const processData = (data: any) => { ... };

// ✅ Good - use unknown with type guard
const processData = (data: unknown) => {
  if (isShipment(data)) {
    // Now TypeScript knows the type
  }
};
```

### Don't ignore TypeScript errors

```typescript
// ❌ Bad
// @ts-ignore
const value = obj.property;

// ✅ Good - fix the actual type issue
const value = (obj as ExpectedType).property;
// or use type guard
if ('property' in obj) {
  const value = obj.property;
}
```

### Don't use non-null assertion carelessly

```typescript
// ❌ Bad - can cause runtime errors
const name = user!.name;

// ✅ Good - handle null case
const name = user?.name ?? 'Unknown';
```

---

## Type checklist

Before submitting:
- [ ] No `any` types - use `unknown` with type guards
- [ ] Using generated types from `@/generated/`
- [ ] Props and emits are fully typed
- [ ] Refs have explicit type annotations
- [ ] Functions have typed parameters and return types
- [ ] Type guards used for runtime type checking

---

## Related skills

| Skill | When to Use |
|-------|-------------|
| **api-integration** | Working with API services and types |
| **vue-component** | Using types in Vue components |
| **unit-testing** | Typing test mocks and fixtures |
