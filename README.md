This repository demonstrates an issue with `ember-tsc`'s dependencies in a v2 addon inside a monorepo. To reproduce:

1. `pnpm install` (using `pnpm@10`, although I think it reproduces with 9 as well)
2. `cd some-addon`
3. `pnpm lint:types`

You should see

```
src/foo.gts:10:29 - error TS2769: No overload matches this call.
  Overload 1 of 3, '(item: DirectInvokable): AnyFunction', gave the following error.
    Argument of type 'typeof Foo' is not assignable to parameter of type 'DirectInvokable'.
      Property '[InvokeDirect]' is missing in type 'typeof Foo' but required in type 'DirectInvokable'.
  Overload 2 of 3, '(item: (abstract new (owner: Owner, args: EmptyObject) => InvokableInstance) | null | undefined): (...args: any[]) => any', gave the following error.
    Argument of type 'typeof Foo' is not assignable to parameter of type 'abstract new (owner: Owner, args: EmptyObject) => InvokableInstance'.
      Types of construct signatures are incompatible.
        Type 'new (owner: Owner, args: EmptyObject) => Foo' is not assignable to type 'abstract new (owner: Owner, args: EmptyObject) => InvokableInstance'.
          Property '[Invoke]' is missing in type 'Foo' but required in type 'InvokableInstance'.
  Overload 3 of 3, '(item: ((...params: any) => any) | null | undefined): (...params: any) => any', gave the following error.
    Argument of type 'typeof Foo' is not assignable to parameter of type '(...params: any) => any'.
      Type 'typeof Foo' provides no match for the signature '(...params: any): any'.

10 export const t = <template><Foo /></template>;
                               ~~~

  ../node_modules/.pnpm/@glint+template@1.7.3/node_modules/@glint/template/-private/integration.d.ts:19:70
    19 export type DirectInvokable<T extends AnyFunction = AnyFunction> = { [InvokeDirect]: T };
                                                                            ~~~~~~~~~~~~~~
    '[InvokeDirect]' is declared here.
  ../node_modules/.pnpm/@glint+template@1.7.3/node_modules/@glint/template/-private/integration.d.ts:22:72
    22 export type InvokableInstance<T extends AnyFunction = AnyFunction> = { [Invoke]: T };
                                                                              ~~~~~~~~
    '[Invoke]' is declared here.


Found 1 error in src/foo.gts:10
```

The type augmentation isn't working, and it appears to be because typescript can't resolve `@glimmer/component` (or `ember-modifier` or `@ember/test-helpers`, but this repository doesn't exercise those augmentations) from [integration-declarations.d.ts](https://github.com/typed-ember/glint/blob/main/packages/core/types/-private/dsl/integration-declarations.d.ts).

I'm not sure why it seems to be resolving the `@ember/*` imports.

It seems that we need to either add all those packages as `peerDependencies` or else update the documentation to tell users in monorepos to install them at the root of the repo? I haven't thoroughly investigated the options yet.
