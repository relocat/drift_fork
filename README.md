> [!NOTE]
> **This is Relocat's fork of [drift](https://github.com/simolus3/drift)**, the reactive persistence
> library for Dart and Flutter by Simon Binder and contributors
> ([documentation](https://drift.simonbinder.eu/)). It is based on the upstream release tag
> `drift-2.32.1` (`ba0cd647b439031808340eceb1ea4fd28b96dcb2`).
>
> **Why it exists.** The [Relocat](https://relocat.org) app targets GrapheneOS (which is based on
> Android 16) with its per-app "Restrict dynamic code loading via memory" exploit-protection setting
> enabled. When opening a database, drift registers its custom SQL functions through
> `package:sqlite3`, which wraps each Dart function in a Dart FFI callback. These callbacks need
> executable trampolines, and that setting blocks the executable-memory allocation. With
> `enableNativeFunctions: false`, drift skips this registration and avoids that allocation.
> This fork does not change anything else in the Dart runtime or in `package:sqlite3`.
>
> **What this fork changes** (only the `drift` package; every other package is upstream as-is):
> - Adds `enableNativeFunctions` (default `true`) to `NativeDatabase()`, `NativeDatabase.memory`,
>   `NativeDatabase.opened`, `NativeDatabase.createInBackground`,
>   `NativeDatabase.createBackgroundConnection` and `Sqlite3Delegate`, including background and
>   read-pool isolates. With `false`, drift skips registering its helper functions
>   (`moor_contains`, `current_time_millis`, `regexp`, …); queries that use them fail with
>   `no such function`.
> - Adds tests in `drift/test/native_database/enable_native_functions_test.dart`.
> - Behaviour is unchanged unless you pass `enableNativeFunctions: false`.
>
> **Licence.** MIT, unchanged from upstream (see [LICENSE](LICENSE)). Our changes are released under
> the same licence.
>
> Relocat is **not affiliated with or endorsed by** the drift maintainers.
>
> **Use upstream drift unless you need this patch.** This fork is not published to pub.dev; depend on
> it by git URL pinned to a commit.
>
> **Issues.** Problems with `enableNativeFunctions` belong
> [here](https://github.com/relocat/drift_fork/issues). Everything else belongs
> [upstream](https://github.com/simolus3/drift/issues). Report security issues privately to
> office@relocat.org.

---

# Drift

[![Build Status](https://github.com/simolus3/drift/actions/workflows/main.yml/badge.svg)](https://github.com/simolus3/drift/actions/workflows/main.yml/badge.svg)
[![Using melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

| Core                                                                                      | Generator                                                                                              |
| :---------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------: |
| [![Main version](https://img.shields.io/pub/v/drift.svg)](https://pub.dev/packages/drift) | [![Generator version](https://img.shields.io/pub/v/drift_dev.svg)](https://pub.dev/packages/drift_dev) |

Drift is a reactive persistence library for Flutter and Dart, built on top of
SQLite.
Drift is

- __Flexible__: Drift lets you write queries in both SQL and Dart,
providing fluent apis for both languages. You can filter and order results
or use joins to run queries on multiple tables. You can even use complex
SQL features like `WITH` and `WINDOW` clauses.
- __🔥 Feature rich__: Drift has builtin support for transactions, schema
migrations, complex filters and expressions, batched updates and joins. We
even have a builtin IDE for SQL!
- __📦 Modular__: Thanks to builtin support for daos and `import`s in SQL files, drift helps you keep your database code simple.
- __🛡️ Safe__: Drift generates type-safe code based on your tables and queries. If you make a mistake in your queries, drift will find it at compile time and
provide helpful and descriptive lints.
- __⚡ Fast__: Even though drift lets you write powerful queries, it can keep
up with the performance of key-value stores like shared preferences and Hive. Drift is the only major persistence library with builtin threading support, allowing you to run database code across isolates with zero additional effort.
- __Reactive__: Turn any SQL query into an auto-updating stream! This includes complex queries across many tables
- __⚙️ Cross-Platform support__: Drift works on Android, iOS, macOS, Windows, Linux and the web. [This template](https://github.com/simolus3/drift/tree/develop/examples/app) is a Flutter todo app that works on all platforms.
- __🗡️ Battle tested and production ready__: Drift is stable and well tested with a wide range of unit and integration tests. It powers production Flutter apps.

With drift, persistence on Flutter is fun!

__To start using drift, read our detailed [docs](https://drift.simonbinder.eu/docs/getting-started/).__

If you have any questions, feedback or ideas, feel free to [create an
issue](https://github.com/simolus3/drift/issues/new). If you enjoy this
project, I'd appreciate your [🌟 on GitHub](https://github.com/simolus3/drift/).

## Sponsors

Drift is proudly Sponsored by [Stream 💙](https://getstream.io/chat/sdk/flutter/?utm_source=Moor&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Moor_July2022_FlutterChatSDK_klmh22)

<p align="center">
<table>
    <tbody>
        <tr>
            <td align="center">
                <a href="https://getstream.io/chat/sdk/flutter/?utm_source=Moor&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Moor_July2022_FlutterChatSDK_klmh22" target="_blank"><img width="250px" src="https://stream-blog.s3.amazonaws.com/blog/wp-content/uploads/fc148f0fc75d02841d017bb36e14e388/Stream-logo-with-background-.png"/></a><br/><span><a href="https://getstream.io/chat/sdk/flutter/?utm_source=Moor&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Moor_July2022_FlutterChatSDK_klmh22" target="_blank">Try the Flutter Chat Tutorial &nbsp💬</a></span>
            </td>
        </tr>
    </tbody>
</table>
</p>

## Working on this project

This repository contains a number of packages making up the drift project, most
notably:

- `drift`: The main runtime for drift, which provides most APIs.
- `drift_dev`: The compiler for drift tables, databases and daos. It
   also contains a fully-featured SQL IDE for the Dart analyzer.
- `sqlparser`: A SQL parser and static analyzer, written in pure Dart. This package can be used without drift to perform analysis on SQL statements.
It's on pub at
[![sqlparser](https://img.shields.io/pub/v/sqlparser.svg)](https://pub.dev/packages/sqlparser)

We use [melos](https://melos.invertase.dev/) to manage the different packages
in this repository.

You can install it with `dart pub global activate melos`. To activate it in this
repository, run `dart pub get` in this directory followed by `melos bootstrap`.

