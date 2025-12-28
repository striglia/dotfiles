---
name: test-driven-bugfix
description: Applies Test-Driven Development to bug fixes by writing failing tests first, then minimal code to fix. Use when fixing bugs, adding test coverage for regressions, or ensuring bugs don't regress. Optimized for JavaScript/TypeScript with Jest/Vitest but principles apply to other languages.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

# TDD Bug Fix Skill

Apply Test-Driven Development to bug fixes by writing failing tests first, then fixing the code.

## When to Use

Invoke when the user reports a bug and wants to:
- Fix a bug using TDD methodology
- Add test coverage for an existing bug
- Ensure bugs don't regress in the future
- Follow the testing pyramid principles

## Core Philosophy

**Red → Green → Refactor**
1. **Red**: Write a failing test that reproduces the bug
2. **Green**: Write minimal code to make the test pass
3. **Refactor**: Clean up if needed (optional)

## Prerequisites

- Test framework configured (e.g., Vitest, Jest)
- Ability to run tests (`npm test`)
- Bug description or reproduction steps

## Workflow

### Phase 1: Understand the Bug

1. **Gather information from user**:
   - What is the expected behavior?
   - What is the actual behavior?
   - How to reproduce?
   - Which component/module is affected?

2. **Identify test level** (Testing Pyramid):
   ```
   E2E Tests          ← Fewest, most expensive
   Integration Tests  ← Moderate
   Unit Tests         ← Most, cheapest, fastest
   ```

   **Decision matrix**:
   - **Unit test** if: Bug in single function/class, no external dependencies
   - **Integration test** if: Bug in interaction between modules
   - **E2E test** if: Bug in full user workflow (use sparingly!)

3. **Locate existing test file or create new one**:
   ```bash
   # Follow convention: place test next to source
   src/components/Widget.js → src/components/Widget.test.js
   src/utils/helper.js → src/utils/helper.test.js
   ```

### Phase 2: Write Failing Test

1. **Create test that reproduces the bug**:
   ```javascript
   describe('BugFix: [Brief description]', () => {
       test('should [expected behavior]', () => {
           // Arrange: Set up test data
           const input = ...;

           // Act: Trigger the buggy code
           const result = buggyFunction(input);

           // Assert: Verify expected behavior
           expect(result).toBe(expectedValue);
       });
   });
   ```

2. **Run test to confirm it fails**:
   ```bash
   npm test -- path/to/test.js
   ```

3. **Verify failure reason matches bug**:
   - Ensure test fails for the right reason
   - Failure message should clearly indicate the bug

### Phase 3: Fix the Code

1. **Make minimal change to pass the test**:
   - Focus on fixing ONLY the reported bug
   - Don't refactor unrelated code
   - Don't add extra features

2. **Run test again**:
   ```bash
   npm test -- path/to/test.js
   ```

3. **Verify test passes**:
   - Green checkmark ✅
   - No unhandled errors
   - Test is deterministic (passes consistently)

### Phase 4: Verify No Regressions

1. **Run full test suite**:
   ```bash
   npm test
   ```

2. **Check for broken tests**:
   - If other tests break, your fix may be incorrect
   - May need to update related tests if behavior intentionally changed

3. **Add edge case tests if needed**:
   - Consider boundary conditions
   - Consider error cases
   - Consider null/undefined inputs

### Phase 5: Commit

1. **Commit with clear message**:
   ```bash
   git add [test-file] [source-file]
   git commit -m "[Component]: Fix [bug description]

   - Added test that reproduces the bug
   - Fixed [specific issue]
   - All tests passing ([X] tests)"
   ```

## Testing Pyramid Guidelines

### Unit Tests (Prefer These!)
**When to use**:
- Bug in pure function
- Bug in class method
- Bug in data transformation
- Bug in validation logic

**Example**:
```javascript
// Bug: formatDate() returns wrong format
test('should format date as YYYY-MM-DD', () => {
    expect(formatDate('2025-01-15')).toBe('2025-01-15');
});
```

### Integration Tests (Use Moderately)
**When to use**:
- Bug in module interaction
- Bug in data flow between components
- Bug in API integration

**Example**:
```javascript
// Bug: DataLoader doesn't handle API errors
test('should return empty array when API fails', async () => {
    mockFetch.mockRejectedValue(new Error('404'));
    const result = await loader.loadData();
    expect(result).toEqual([]);
});
```

### E2E Tests (Use Sparingly!)
**When to use**:
- Bug in critical user workflow
- Bug that only manifests in full app context
- Bug in browser-specific behavior

**Example**:
```javascript
// Bug: Drag-and-drop doesn't work in Kanban board
test('should move task between columns', () => {
    const card = page.getByTestId('task-1');
    const column = page.getByTestId('in-progress-column');
    await card.dragTo(column);
    expect(await column.getByTestId('task-1')).toBeVisible();
});
```

## Common Patterns

### Pattern 1: Null/Undefined Handling
```javascript
// Bug: Function crashes on null input
test('should handle null input gracefully', () => {
    expect(() => processData(null)).not.toThrow();
    expect(processData(null)).toBe(null); // or default value
});
```

### Pattern 2: Edge Cases
```javascript
// Bug: Loop fails on empty array
test('should handle empty array', () => {
    expect(sumArray([])).toBe(0);
});
```

### Pattern 3: Async Errors
```javascript
// Bug: Promise rejection not caught
test('should handle async errors', async () => {
    await expect(fetchData('invalid')).rejects.toThrow();
});
```

### Pattern 4: State Management
```javascript
// Bug: State not updated correctly
test('should update state when action dispatched', () => {
    store.dispatch(action);
    expect(store.getState()).toEqual(expectedState);
});
```

### Pattern 5: DOM Manipulation
```javascript
// Bug: Element not removed from DOM
test('should remove element when deleted', () => {
    component.delete();
    expect(document.querySelector('.item')).toBeNull();
});
```

## Example: Real Bug Fix

**Bug Report**: "Drag-and-drop in Kanban board doesn't work - cards don't move between columns"

### Step 1: Write Failing Test
```javascript
test('should update task status when dropped in different column', () => {
    const kanbanView = new KanbanBoardView(tasks);
    const element = kanbanView.render();
    document.body.appendChild(element);

    const card = element.querySelector('[data-task-id="task-1"]');
    const inProgressColumn = element.querySelector('[data-status="in_progress"]');

    // Simulate drag-and-drop
    const dragEvent = new DragEvent('dragstart', { ... });
    card.dispatchEvent(dragEvent);

    const dropEvent = new DragEvent('drop', { ... });
    inProgressColumn.dispatchEvent(dropEvent);

    // Verify status updated
    const task = tasks.find(t => t.id === 'task-1');
    expect(task.status).toBe('in_progress'); // FAILS - status not updated
});
```

### Step 2: Run Test (Fails ❌)
```bash
$ npm test -- kanbanBoard.test.js
Expected: 'in_progress'
Received: 'pending'
```

### Step 3: Fix Code
```javascript
_handleDrop(event) {
    // ... existing code ...

    // FIX: Actually update the task status!
    task.status = newStatus;

    // FIX: Re-render only if mounted
    if (this.element && this.element.parentNode) {
        this.update(this.allTasks);
    }
}
```

### Step 4: Run Test (Passes ✅)
```bash
$ npm test -- kanbanBoard.test.js
✓ should update task status when dropped in different column
```

### Step 5: Run Full Suite
```bash
$ npm test
✓ All 45 tests passing
```

### Step 6: Commit
```bash
git add src/js/components/kanbanBoard.{js,test.js}
git commit -m "Add drag-and-drop tests and fix implementation

- Created test reproducing drag-and-drop bug
- Fixed _handleDrop to update task status
- Fixed update() method to handle DOM replacements
- All 45 tests passing"
```

## Tips for Success

1. **One test, one bug**: Don't try to fix multiple bugs in one test
2. **Test the bug, not the implementation**: Focus on observable behavior
3. **Start with the simplest test**: Add complexity only if needed
4. **Mock external dependencies**: Keep tests fast and isolated
5. **Use descriptive test names**: "should X when Y" format
6. **Verify test fails for right reason**: Don't trust a test that never failed
7. **Keep tests maintainable**: Follow DRY principles, use helpers
8. **Run tests frequently**: Red → Green cycle should be quick

## Anti-Patterns to Avoid

❌ **Don't write test after the fix**: That's not TDD!
❌ **Don't skip the failing test phase**: Always verify test can fail
❌ **Don't test implementation details**: Test behavior, not internals
❌ **Don't make tests dependent**: Each test should run independently
❌ **Don't write vague tests**: Be specific about expected behavior
❌ **Don't over-mock**: Mock only what you need
❌ **Don't ignore flaky tests**: Fix or remove them

## When NOT to Use TDD

- **Exploratory prototyping**: When you're still figuring out the approach
- **Trivial changes**: One-line typo fixes don't need tests
- **Experimental features**: May be deleted soon
- **Performance tuning**: Unless testing performance thresholds
- **Visual design tweaks**: CSS changes (use design iteration skill instead)

## Integration with Other Skills

- **After fixing**: Use design-iterate skill if UI bug
- **Before merging**: Use git-workflow skill to create PR
- **Code review feedback**: Use fix-pr-feedback skill

## Success Metrics

- ✅ Test written before fix
- ✅ Test fails initially
- ✅ Minimal code change to pass
- ✅ All existing tests still pass
- ✅ Bug cannot regress (test will catch it)
- ✅ Testing pyramid principles followed
