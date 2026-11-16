---
name: structs-methods-over-functions
description: >-
  When developing in Sal (or any language), prefer using structs with methods over standalone functions.
  This improves cohesion, encapsulation, and makes the code easier to understand and maintain.
  Use a struct when:
  - The data and behavior belong together (e.g., fields like `name`, `size` plus methods like `calculate_area()`).
  - You have multiple related functions that operate on similar data; bundle them into methods of a struct.
  - You need to carry state between operations; use the struct field instead of passing separate params.
  - The function does more than one logical thing (e.g., `create_user` and `validate_email`) — group under a `UserBuilder` or similar.
  
  Avoid:
  - Global functions that take multiple unrelated parameters.
  - Functions with many required params that describe the data shape.
  Instead, define a struct with those fields and write methods on it. Methods can be private (no export) if they're internal helpers.
  
  Example pattern in Sal:

  ```sal
  // Instead of:
  fn calculate_area(width: Int, height: Int) -> Int { width * height }
  fn create_rectangle(width: Int, height: Int) -> Rectangle {
      Rectangle{ width: width, height: height }
  }
  
  // Use a struct:
  struct Rectangle {
      width: Int
      height: Int
  }
  
  fn (r: Rectangle) calculate_area() -> Int { r.width * r.height }
  fn (r: Rectangle) create_rectangle(width: Int, height: Int) -> Rectangle {
      Rectangle{ width: width, height: height }
  }
  // Or better:
  fn Rectangle::new(width: Int, height: Int) -> Rectangle { Rectangle{ width, height } }
  fn (r: Rectangle) area() -> Int { r.width * r.height }
  ```

  Benefits:
  - Data and behavior are colocated.
  - Easier to add new related methods without changing function signatures.
  - Less boilerplate parameter passing.
  - Better IDE/tooling support (autocomplete on struct).
  - More intuitive API: `rect.area()` vs `calculate_area(rect)`

  When NOT to use a struct:
  - The data is transient or purely computational (e.g., math helpers that don't need state).
  - The behavior is truly generic and doesn't depend on the data shape.
  In those cases, plain functions are fine.

  This skill guides the agent to prefer structs+methods when appropriate, especially in Sal projects.
---
