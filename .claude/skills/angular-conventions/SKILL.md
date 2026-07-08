---
description: angular-conventions conventions for this project. Applies to projects that contain angular.json.
---

- All scaffolding and maintenance goes through the Angular CLI —
`ng generate component|service|guard|…` for new artifacts, `ng update` for
framework upgrades, `ng add` for integrating libraries. Never hand-create
component files or hand-edit framework versions in `package.json`; the CLI
applies schematics and migrations that manual edits miss.
- Every component, directive, and pipe is standalone (the default — do not write
`standalone: true` explicitly, and never `standalone: false`). No new NgModules;
compose via component `imports` and provide app-wide services with
`providedIn: "root"` or route-level `providers`.
- Component and service state is signal-based: `signal()` for writable state,
`computed()` for derivation, `linkedSignal()` for resettable derived state, and
`effect()` only for synchronizing with non-Angular code. Use the function-based
component API — `input()`, `output()`, `model()`, `viewChild()`,
`contentChild()` — never the decorator forms `@Input`/`@Output`/`@ViewChild`.

```typescript
@Component({/* … */})
export class CartItemComponent {
  readonly item = input.required<CartItem>();
  readonly quantity = model(1);
  readonly removed = output<string>();

  protected readonly lineTotal = computed(() =>
    this.item().price * this.quantity()
  );
}
```
- Load async data with the resource APIs — `httpResource` for HTTP reads,
`resource()` for other async sources, `rxResource` when the source is an
Observable — and render their `value`/`isLoading`/`error` signals. Do not
hand-roll fetch-then-set-signal plumbing or manage subscriptions for data
loading. Mutations (POST/PUT/DELETE) still go through `HttpClient` in a service.
- Applications run zoneless: `provideZonelessChangeDetection()` in
`app.config.ts`, no `zone.js` polyfill, and `ChangeDetectionStrategy.OnPush` on
every component. State changes flow through signals so the framework knows what
to update; never call `detectChanges()` manually.
- Templates use the built-in control flow — `@if`/`@else`, `@for` with a mandatory
`track` expression, `@switch`, and `@defer` for below-the-fold or heavy
components — never `*ngIf`/`*ngFor`/`*ngSwitch`.

```html
@for (order of orders(); track order.id) {
  <app-order-row [order]="order" (removed)="remove($event)" />
} @empty {
  <p>No orders yet.</p>
}
```
- Use `inject()` in field initializers instead of constructor parameter injection;
it composes into reusable functions and keeps classes free of boilerplate
constructors.

```typescript
export class OrderService {
  readonly #http = inject(HttpClient);
  readonly #config = inject(APP_CONFIG);
}
```
- Routes lazy-load (`loadComponent`/`loadChildren`) by default,
guards/resolvers/interceptors are plain functions (`CanActivateFn`,
`HttpInterceptorFn`), and route params bind to component inputs via
`withComponentInputBinding()`.
- Every component/service ships with `TestBed`-based unit tests that exercise the
public surface: set inputs via `fixture.componentRef.setInput()`, assert on
rendered DOM and emitted outputs, stub HTTP with `provideHttpClientTesting()`.
Zoneless tests await `fixture.whenStable()` rather than calling
`fixture.detectChanges()` after every change.
