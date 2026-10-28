const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const { validarTamanos } = require('../src/tamanos');

describe('validarTamanos', () => {
  describe('estructura del arreglo', () => {
    test('rechaza si tamanos no es un arreglo', () => {
      assert.match(validarTamanos(null), /arreglo/i);
      assert.match(validarTamanos(undefined), /arreglo/i);
      assert.match(validarTamanos('ch'), /arreglo/i);
      assert.match(validarTamanos(123), /arreglo/i);
      assert.match(validarTamanos({}), /arreglo/i);
      assert.match(validarTamanos(true), /arreglo/i);
    });

    test('acepta un arreglo vacio devolviendo null', () => {
      assert.equal(validarTamanos([]), null);
    });

    test('rechaza si un elemento no es un objeto valido', () => {
      assert.match(validarTamanos([null]), /objeto/i);
      assert.match(validarTamanos(['ch']), /objeto/i);
      assert.match(validarTamanos([123]), /objeto/i);
      assert.match(validarTamanos([[]]), /objeto/i);
    });
  });

  describe('validacion del campo tamano', () => {
    test('rechaza si falta el campo tamano', () => {
      const err = validarTamanos([{ precio_centavos: 3000 }]);
      assert.ok(err, 'Debe devolver un mensaje de error');
      assert.match(err, /tamano|tamaño/i);
    });

    test('rechaza si tamano no pertenece a ch, md, g, xl', () => {
      assert.match(validarTamanos([{ tamano: 'grande', precio_centavos: 3000 }]), /ch, md, g, xl/i);
      assert.match(validarTamanos([{ tamano: 'xxl', precio_centavos: 3000 }]), /ch, md, g, xl/i);
      assert.match(validarTamanos([{ tamano: '', precio_centavos: 3000 }]), /ch, md, g, xl/i);
      assert.match(validarTamanos([{ tamano: 1, precio_centavos: 3000 }]), /ch, md, g, xl/i);
    });

    test('acepta cada uno de los cuatro tamanos validos (ch, md, g, xl)', () => {
      assert.equal(validarTamanos([{ tamano: 'ch', precio_centavos: 2500 }]), null);
      assert.equal(validarTamanos([{ tamano: 'md', precio_centavos: 3000 }]), null);
      assert.equal(validarTamanos([{ tamano: 'g', precio_centavos: 3500 }]), null);
      assert.equal(validarTamanos([{ tamano: 'xl', precio_centavos: 4000 }]), null);
    });
  });

  describe('validacion del campo precio_centavos', () => {
    test('rechaza si falta el campo precio_centavos o no es numero', () => {
      assert.match(validarTamanos([{ tamano: 'ch' }]), /precio_centavos/i);
      assert.match(validarTamanos([{ tamano: 'ch', precio_centavos: '3000' }]), /precio_centavos/i);
      assert.match(validarTamanos([{ tamano: 'ch', precio_centavos: null }]), /precio_centavos/i);
      assert.match(validarTamanos([{ tamano: 'ch', precio_centavos: undefined }]), /precio_centavos/i);
    });

    test('rechaza si precio_centavos no es un entero', () => {
      assert.match(validarTamanos([{ tamano: 'ch', precio_centavos: 25.5 }]), /entero/i);
      assert.match(validarTamanos([{ tamano: 'ch', precio_centavos: NaN }]), /entero/i);
      assert.match(validarTamanos([{ tamano: 'ch', precio_centavos: Infinity }]), /entero/i);
    });

    test('rechaza si precio_centavos es menor a 0', () => {
      assert.match(validarTamanos([{ tamano: 'ch', precio_centavos: -1 }]), /mayor o igual a 0/i);
      assert.match(validarTamanos([{ tamano: 'ch', precio_centavos: -100 }]), /mayor o igual a 0/i);
    });

    test('acepta precio_centavos igual a 0', () => {
      assert.equal(validarTamanos([{ tamano: 'ch', precio_centavos: 0 }]), null);
    });

    test('acepta precio_centavos entero mayor a 0', () => {
      assert.equal(validarTamanos([{ tamano: 'ch', precio_centavos: 3200 }]), null);
    });
  });

  describe('devolucion del primer error y multiples elementos', () => {
    test('devuelve el error del primer elemento invalido', () => {
      const err = validarTamanos([
        { tamano: 'invalido', precio_centavos: 3000 },
        { tamano: 'g', precio_centavos: -50 },
      ]);
      assert.match(err, /ch, md, g, xl/i);
    });

    test('devuelve el error del segundo elemento si el primero es valido', () => {
      const err = validarTamanos([
        { tamano: 'ch', precio_centavos: 3000 },
        { tamano: 'g', precio_centavos: -50 },
      ]);
      assert.match(err, /precio_centavos|mayor o igual a 0/i);
    });

    test('devuelve null cuando todos los elementos son validos', () => {
      const lista = [
        { tamano: 'ch', precio_centavos: 2800 },
        { tamano: 'md', precio_centavos: 3300 },
        { tamano: 'g', precio_centavos: 3800 },
        { tamano: 'xl', precio_centavos: 4400 },
      ];
      assert.equal(validarTamanos(lista), null);
    });
  });
});
