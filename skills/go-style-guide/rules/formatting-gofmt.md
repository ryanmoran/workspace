---
title: Always Use gofmt
impact: CRITICAL
impactDescription: Universal consistency across all Go codebases
tags: formatting, gofmt, consistency
---

## Always Use gofmt

All Go source files must conform to `gofmt` output. No exceptions - this ensures
universal consistency across all Go projects.

**Why this matters:** `gofmt` eliminates debates about formatting and ensures
every Go codebase looks familiar to every Go programmer. This dramatically
reduces cognitive load and review friction.

**For LLM agents:**

- Always format code using `gofmt` before presenting it
- Run `gofmt -w <file>` to format Go files in place
- Ensure all generated code conforms to `gofmt` standards
- You can verify formatting with `gofmt -d <file>` (shows diff if not formatted)

**Incorrect (manually formatted):**

```go
func example(x int,y int){
    if x>0{
return x+y
    }
return 0
}
```

**Correct (gofmt formatted):**

```go
func example(x int, y int) {
    if x > 0 {
        return x + y
    }
    return 0
}
```

**Line Length:**

Unlike many style guides, Go has no fixed line length restriction. However:

- Prefer refactoring over artificial line splitting
- Avoid splitting lines before indentation changes
- Let code naturally flow; break only when it improves readability

**Incorrect (artificial splitting that doesn't help readability):**

```go
if err := processLongFunctionName(context, parameter1,
    parameter2, parameter3); err != nil {
    return fmt.Errorf("processing failed: %w", err)
}
```

**Correct (natural flow):**

```go
if err := processLongFunctionName(context, parameter1, parameter2, parameter3); err != nil {
    return fmt.Errorf("processing failed: %w", err)
}
```

**Alternative (refactor if truly too long):**

```go
err := processLongFunctionName(context, parameter1, parameter2, parameter3)
if err != nil {
    return fmt.Errorf("processing failed: %w", err)
}
```
