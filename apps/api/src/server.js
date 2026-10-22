const app = require('./app');

const port = process.env.PORT || 3000;
app.listen(port, (err) => {
  if (err) throw err; // sin esto, un puerto ocupado pasa sin avisar
  console.log(`API en http://localhost:${port}`);
});
