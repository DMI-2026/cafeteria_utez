const express = require('express');
const cors = require('cors');
const productosRouter = require('./productos');
const usuariosRouter = require('./usuarios');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/productos', productosRouter);
app.use('/usuarios', usuariosRouter);

module.exports = app;
