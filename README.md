# Lagrange

Nothing to see yet, move along.

## Running Tests

To run the tests, simply run:

```bash
rake test
```

If you wish to produce coverage analysis as well:

```bash
rake test:coverage
```

Then see `coverage/index.html` for the results.

If you see stale data, run:

```bash
rake clobber
```

To clear old coverage stats before running `rake test:coverage` again.


## Generating Documentation

This project uses YARD for documentation.  Just run the rake task:

```bash
rake yard
```

Then see `doc/index.html` for the results.
