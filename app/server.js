const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const pr = process.env.PR_NUMBER || 'local';

app.get('/', (req, res) => {
  res.send(`<h1>PR Preview</h1><p>This is preview for <strong>PR #${pr}</strong>.</p>`);
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
