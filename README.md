# ClimaTrack | Proyecto de prácticas FP DAM

## Descripción
**ClimaTrack** es una herramienta de trabajo interna (B2E) diseñada como una aplicación móvil para técnicos e instaladores de gas y aire acondicionado. La aplicación puede ser gestionada tanto por los administradores de la aplicación como por los técnicos que consultan los partes de trabajo en su Agenda del Día.

## Tecnologías y Herramientas
El proyecto está desarrollado empleando el siguiente stack tecnológico:

* **Lenguaje de Programación:** Dart
* **Framework Frontend:** Flutter 
* **Backend & Base de Datos:** Firebase (Firebase Auth,  Firestore)
* **Diseño UI/UX:** Figma 

---

## Estructura de Directorios

- **lib/pages/**: Contiene todas las páginas de la interfaz de usuario.
  - **agenda_dia/**: Gestiona la pantalla "Agenda del Día".
    - agenda_dia_page.dart: Archivo principal de la página Agenda del Día.
    - widgets/
      - work_order_item.dart: Widget que representa un elemento de orden de trabajo.
  - **admin_home/**: Funcionalidades del panel de administración.
    - admin_home.dart: Archivo principal de la página de inicio del administrador.
    - work_order_detail_page.dart: Página para ver los detalles de una orden de trabajo específica.
    - work_order_card.dart: Widget de tarjeta para mostrar órdenes de trabajo.
    - assign_work_modal.dart: Modal para asignar órdenes de trabajo.
  - **create_work_orders/**: Gestiona la creación de nuevas órdenes de trabajo.
    - create_work_order_page.dart: Archivo principal para crear órdenes de trabajo.
  - **installer_home/**: Pantalla de inicio para técnicos.
    - installer_home.dart: Archivo principal de la página de inicio del técnico.
  - **manage_clients/**: Funcionalidades de gestión de clientes.
    - add_clients_page.dart: Página para añadir nuevos clientes.
    - client_details_page.dart: Página para ver los detalles de un cliente específico.
    - edit_client_page.dart: Página para editar clientes existentes.
    - manage_clients_page.dart: Archivo principal para la gestión de clientes.
  - **manage_installers/**: Funcionalidades de gestión de instaladores.
    - add_installers_page.dart: Página para añadir nuevos instaladores.
    - manage_installers.dart: Archivo principal para la gestión de instaladores.
  - **parte_trabajo_form/**: Funcionalidades del formulario del parte de trabajo.
    - parte_trabajo_form.dart: Archivo principal del formulario del parte de trabajo.
    - widgets/
      - estado_selector_modal.dart: Modal para seleccionar el estado de la orden de trabajo.
      - material_selector_modal.dart: Modal para seleccionar materiales.

- **lib/models/**: Contiene los modelos de datos.
  - client.dart: Modelo de clientes.
  - material.dart: Modelo de materiales.
  - work_order.dart: Modelo de órdenes de trabajo.

- **lib/providers/**: Gestiona el estado de la aplicación mediante providers.
  - agenda_provider.dart
  - admin_calendar_provider.dart
  - auth_provider.dart
  - material_provider.dart
  - work_order_assignment_provider.dart
  - work_order_provider.dart

- **lib/repository/**: Gestiona la obtención y almacenamiento de datos.
  - client_repository.dart
  - material_repository.dart
  - work_order_assignment_repository.dart
  - work_order_repository.dart
  - work_type_duration_repository.dart

- **lib/services/**: Contiene los servicios de utilidad.
  - auth.dart: Servicio de autenticación.
  - notification_service.dart: Servicio de notificaciones.

- **lib/widgets/**: Componentes de la interfaz de usuario reutilizables.
  - app_buttons.dart: Botones utilizados en la aplicación.
  - app_inputs.dart: Campos de entrada utilizados en la aplicación.
  - app_colors.dart: Constantes de colores de la aplicación.
  - app_textstyles.dart: Constantes de estilos de texto de la aplicación.

- **main.dart**: Punto de entrada de la aplicación.

---

## Instrucciones de instalación
1. Clona el repositorio.
2. Navega hasta el directorio del proyecto.
3. Ejecuta `flutter pub get` para instalar todas las dependencias.
4. Conecta tu dispositivo o emulador.
5. Ejecuta la aplicación con `flutter run`.