# Basic Code Review

## Input

Review this React component:

```tsx
function UserList({ users }: { users: User[] }) {
  const [selectedUser, setSelectedUser] = useState<User | null>(null);

  const handleSelect = (user: User) => {
    setSelectedUser(user);
  };

  return (
    <div>
      {users.map((user) => (
        <button key={user.id} onClick={() => handleSelect(user)}>
          {user.name}
        </button>
      ))}

      {selectedUser && <div>{selectedUser.name}</div>}
    </div>
  );
}
```

The component is part of a user-management application.

## Expected

Review the code for meaningful correctness, React, TypeScript, accessibility, maintainability, and testability issues.

The review should:

- Identify concrete problems supported by the code.
- Consider whether the interactive elements are accessible.
- Consider whether the component has unnecessary complexity.
- Avoid reporting issues that are only personal style preferences.
- Distinguish real defects from optional improvements.
- Provide severity, location, problem, evidence, impact, and recommended fix for substantive findings.

The review should not invent requirements that are not present in the input.
