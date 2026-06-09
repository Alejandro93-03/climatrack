# Modelos de Datos

Esta carpeta contiene las clases Dart que representan las colecciones de Firestore.

## WorkOrder
Representa un parte de trabajo. Colección: `work_orders`.
- Métodos: `fromMap`, `toMap`, `copyWith`
- Validaciones: `type` y `status` solo aceptan valores definidos en la guía del proyecto

## Client
Representa un cliente. Colección: `clients`.
- Métodos: `fromMap`, `toMap`
- Incluye lista de equipos instalados (`installations`)

## Material
Representa un material del catálogo. Colección: `materials`.
- Métodos: `fromMap`, `toMap`
- Validaciones: `unit` y `category` solo aceptan valores definidos en la guía del proyecto