---
name: rust-development
description: Use when writing Rust code, fixing borrow checker errors, resolving lifetime issues, debugging trait bounds, or implementing fearless concurrency patterns
---

# Rust Development

Guidelines for safe, performant, and idiomatic Rust code.

## When to Use

- Borrow checker errors ("cannot borrow as mutable")
- Lifetime annotation issues
- Trait bound compilation errors
- Memory safety requirements
- Systems programming tasks
- High-performance concurrent code

## When NOT to Use

- Prototyping with frequent schema changes (use Python)
- Simple scripts (use Bash/Python)
- When compilation time is critical

## Core Principles

1. **Memory Safety** - Leverage ownership system for zero-cost safety
2. **Performance** - Zero-cost abstractions and efficient code
3. **Fearless Concurrency** - Safe parallel programming
4. **Explicit Error Handling** - Use Result<T, E> and Option<T>
5. **Idiomatic Patterns** - Follow Rust conventions

## Ownership and Borrowing

### Basic Rules
```rust
// Each value has a single owner
let s1 = String::from("hello");
let s2 = s1; // s1 moved, no longer valid

// Borrow without taking ownership
fn length(s: &String) -> usize { s.len() }

// Mutable references are exclusive
let mut s = String::from("hello");
let r1 = &mut s;
// let r2 = &mut s; // ❌ Cannot have two mutable refs
```

### Common Patterns
```rust
// Multiple immutable borrows OK
let s = String::from("hello");
let r1 = &s;
let r2 = &s; // ✅

// Scoping mutable borrow
let mut s = String::from("hello");
{
    let r1 = &mut s;
    r1.push_str(", world");
} // r1 goes out of scope
println!("{}", s); // ✅
```

## Error Handling

### Result<T, E>
```rust
use std::fs::File;
use std::io::Read;

// ❌ Don't unwrap() in production
fn read_file_bad(path: &str) -> String {
    let mut file = File::open(path).unwrap(); // Panics on error
    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();
    contents
}

// ✅ Proper error handling with ? operator
fn read_file(path: &str) -> Result<String, std::io::Error> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

// ✅ Custom error types
#[derive(Debug)]
enum ConfigError {
    Io(std::io::Error),
    Parse(String),
}

impl From<std::io::Error> for ConfigError {
    fn from(err: std::io::Error) -> Self {
        ConfigError::Io(err)
    }
}
```

### Option<T>
```rust
fn find_user(id: u32) -> Option<User> { /* ... */ }

// Pattern matching
match find_user(123) {
    Some(user) => println!("Found: {}", user.name),
    None => println!("User not found"),
}

// Combinators
let name = find_user(123)
    .map(|user| user.name)
    .unwrap_or_else(|| "Unknown".to_string());
```

## Memory Management

### Smart Pointers
```rust
use std::rc::Rc;
use std::sync::Arc;
use std::cell::RefCell;

// Reference counting (single-threaded)
let data = Rc::new(vec![1, 2, 3]);
let data_clone = Rc::clone(&data);

// Thread-safe reference counting
let shared = Arc::new(vec![1, 2, 3]);
let thread_data = Arc::clone(&shared);

// Interior mutability
let data = RefCell::new(vec![1, 2, 3]);
data.borrow_mut().push(4);
```

### Lifetimes
```rust
// Explicit lifetime annotations
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

// Struct with lifetime
struct Excerpt<'a> {
    part: &'a str,
}

impl<'a> Excerpt<'a> {
    fn level(&self) -> i32 { 3 }
}
```

## Concurrency

### Thread Safety with Arc<Mutex<T>>
```rust
use std::sync::{Arc, Mutex};
use std::thread;

let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = Arc::clone(&counter);
    let handle = thread::spawn(move || {
        *counter.lock().unwrap() += 1;
    });
    handles.push(handle);
}

for handle in handles {
    handle.join().unwrap();
}
```

### Async/Await (Tokio)
```rust
use tokio;

async fn fetch_data(url: &str) -> Result<String, reqwest::Error> {
    let body = reqwest::get(url).await?.text().await?;
    Ok(body)
}

// Concurrent async operations
async fn fetch_multiple() -> Result<Vec<String>, Box<dyn std::error::Error>> {
    let urls = vec!["https://api1.com", "https://api2.com"];
    let futures: Vec<_> = urls.iter().map(|&url| fetch_data(url)).collect();
    let results = futures::future::try_join_all(futures).await?;
    Ok(results)
}
```

## Performance

### Zero-Cost Abstractions
```rust
// Iterator chains compile to efficient loops
let sum: i32 = (0..1_000_000)
    .filter(|x| x % 2 == 0)
    .map(|x| x * x)
    .sum();

// Use slices over Vec when possible
fn analyze(data: &[f64]) -> f64 {
    data.iter().sum::<f64>() / data.len() as f64
}
```

### Memory Efficiency
```rust
// Box large stack allocations
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    ChangeColor(Box<[u8; 1024]>), // Box large arrays
}
```

## Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculation() {
        assert_eq!(calculate(2, 2), 4);
    }

    #[test]
    #[should_panic(expected = "divide by zero")]
    fn test_divide_by_zero() {
        divide(10, 0);
    }

    #[test]
    fn test_result() -> Result<(), Box<dyn std::error::Error>> {
        let result = risky_operation()?;
        assert_eq!(result, "success");
        Ok(())
    }
}

// Property-based testing
use quickcheck::quickcheck;

#[quickcheck]
fn prop_reverse_involutive(xs: Vec<u32>) -> bool {
    let reversed: Vec<_> = xs.iter().rev().rev().cloned().collect();
    xs == reversed
}
```

## Best Practices Checklist

- [ ] Use `cargo clippy` for linting
- [ ] Run `cargo fmt` for formatting
- [ ] Handle all Result/Option cases explicitly
- [ ] Prefer borrowing over taking ownership
- [ ] Use iterators over manual loops
- [ ] Implement proper Error types for libraries
- [ ] Add comprehensive documentation with `///`
- [ ] Use `#[deny(missing_docs)]` for public APIs
- [ ] Profile with `cargo flamegraph` for performance
- [ ] Test with `cargo test` and property-based tests

## Common Patterns

### Builder Pattern
```rust
pub struct Config {
    host: String,
    port: u16,
    timeout: Duration,
}

pub struct ConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    timeout: Option<Duration>,
}

impl ConfigBuilder {
    pub fn new() -> Self {
        Self { host: None, port: None, timeout: None }
    }

    pub fn host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }

    pub fn build(self) -> Result<Config, String> {
        Ok(Config {
            host: self.host.ok_or("host required")?,
            port: self.port.unwrap_or(8080),
            timeout: self.timeout.unwrap_or(Duration::from_secs(30)),
        })
    }
}
```

### Type-State Pattern
```rust
pub struct Pending;
pub struct Running;

pub struct Task<State = Pending> {
    id: u32,
    _state: PhantomData<State>,
}

impl Task<Pending> {
    pub fn new(id: u32) -> Self {
        Task { id, _state: PhantomData }
    }
    pub fn start(self) -> Task<Running> {
        Task { id: self.id, _state: PhantomData }
    }
}
```

## Anti-Patterns

```rust
// ❌ Over-using Clone
fn bad(data: Vec<String>) -> Vec<String> {
    data.clone() // Unnecessary allocation
}

// ✅ Work with borrowing
fn good(data: &[String]) -> Vec<&str> {
    data.iter().map(|s| s.as_str()).collect()
}

// ❌ Panic-prone unwrap()
let value = risky().unwrap();

// ✅ Handle errors properly
let value = risky().unwrap_or_else(|e| {
    eprintln!("Failed: {}", e);
    default_value()
});
```

## Quick Reference

| Tool | Command | Purpose |
|------|---------|---------|
| Check | `cargo check` | Fast syntax/type check |
| Lint | `cargo clippy` | Catch common mistakes |
| Format | `cargo fmt` | Format code |
| Test | `cargo test` | Run tests |
| Docs | `cargo doc --open` | Generate docs |
| Profile | `cargo flamegraph` | Performance analysis |

## Common Compiler Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "cannot borrow as mutable" | Multiple mutable refs | Use scopes or refactor |
| "does not live long enough" | Lifetime too short | Add lifetime annotation |
| "trait bounds not satisfied" | Missing trait impl | Derive or implement trait |
| "move occurs because..." | Value moved | Use reference or clone |

## Remember

> The compiler is your friend. When fighting the borrow checker, step back and consider if your design could be improved rather than working around the constraints.