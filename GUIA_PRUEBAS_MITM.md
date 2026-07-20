# Guía de Pruebas: SSL Pinning y Ataque MitM

Esta guía detalla paso a paso cómo realizar las pruebas para interceptar el tráfico y obtener las capturas necesarias para el reporte de la actividad, demostrando que el SSL Pinning funciona correctamente.

Se asume el uso de **Android** (Emulador o Físico) y **OWASP ZAP** como herramienta para realizar el ataque Man-in-the-Middle (MitM). El proceso es muy similar si decides usar Charles Proxy.

---

## Parte 1: Captura de Conexión Normal (Sin Ataque)

Esta prueba demuestra que la aplicación funciona correctamente cuando no hay ninguna intercepción en la red y el certificado del servidor original coincide con nuestra huella digital.

1. **Inicia la aplicación:** Ejecuta el proyecto en tu dispositivo físico o emulador (`flutter run`). 
   - *Importante:* Asegúrate de que no haya ningún proxy activo en la red Wi-Fi de tu teléfono/emulador en este momento.
2. **Interactúa con la app:** Navega por la aplicación, intenta iniciar sesión o realiza cualquier acción que consulte la API (`sums-api.troy.engineer`).
3. **Toma la Captura 1:** Toma una captura de pantalla de tu celular donde se evidencie que la app cargó los datos con éxito o que inició sesión sin problemas. 
   - Esta será tu **primera captura** para el reporte (Conexión Exitosa).

---

## Parte 2: Preparar el ataque MitM (Interceptación)

Ahora configuraremos la red para forzar a que todo el tráfico de la app pase por nuestra computadora, simulando un atacante escuchando la red.

### Paso A: Configurar el Proxy en tu Computadora (OWASP ZAP)

1. Abre **OWASP ZAP** en tu computadora.
2. Ve a **Opciones** (el ícono de engranaje) > **Local Proxies** (o Proxies Locales).
3. Verifica la dirección IP y el puerto en el que ZAP está escuchando:
   - **Puerto:** Suele ser el `8080`.
   - **Dirección IP:**
     - Si usas un celular **físico**, ZAP debe escuchar en tu IP de red local (ej. `192.168.1.XX`).
     - Si usas un **emulador** (ej. Android Studio), usar `localhost` en ZAP es suficiente.

### Paso B: Configurar el Proxy en el Celular / Emulador

1. Ve a los **Ajustes** (Configuración) de tu celular o emulador Android.
2. Ve a **Redes e Internet** > **Wi-Fi**.
3. Deja presionado el nombre de tu red Wi-Fi actual y selecciona **Modificar red** (o el ícono de un lápiz/engranaje).
4. En **Opciones Avanzadas**, busca la configuración de **Proxy** y cámbiala de "Ninguno" a **Manual**.
5. Ingresa los datos del proxy:
   - **Nombre del host (Proxy hostname):**
     - Si es celular físico: La IP de tu computadora (ej. `192.168.1.XX`).
     - Si es emulador de Android: Ingresa `10.0.2.2` (esta IP redirige al localhost de tu computadora).
   - **Puerto:** `8080` (o el que te haya indicado ZAP).
6. Guarda los cambios. A partir de este momento, todo el tráfico de internet de tu celular intentará pasar por OWASP ZAP.

> ⚠️ **REGLA DE ORO PARA EL PINNING:** Para probar que el Pinning funciona correctamente y rechaza conexiones inseguras, **NO debes instalar el certificado de ZAP en tu teléfono**. Queremos que el celular detecte a ZAP como un "intruso" precisamente porque el certificado que ZAP presenta no coincide con el que configuramos de forma estricta (el SHA-256 de tu API).

---

## Parte 3: Captura de Conexión Bloqueada (Con Ataque MitM)

En este punto comprobaremos que el SSL Pinning hace su trabajo y aborta la conexión comprometida.

1. Con el proxy (ZAP) encendido e interceptando, y el celular conectado a dicho proxy, **abre nuevamente tu aplicación Flutter**.
   - ⚠️ **Cierra sesión primero (si ya iniciaste sesión en la Parte 1):** la app tiene un mecanismo de *login offline* que, si detecta una sesión guardada localmente, te deja entrar usándola aunque el pinning haya rechazado el certificado del servidor — esto oculta el bloqueo sin que te des cuenta. Ve a "Cerrar sesión" en la app antes de continuar, para forzar un login real contra el servidor.
2. Intenta realizar la misma acción que en la Parte 1 (ej. iniciar sesión o recargar datos).
3. **Comprobación:** En lugar de cargar los datos o permitir el inicio de sesión, la aplicación **fallará de inmediato**. Deberías ver en la pantalla el mensaje de error controlado que se configuró en el código: `"Posible ataque MitM. Certificado de sums-api.troy.engineer es inválido."` (o una alerta visual de error de conexión/API).
4. **Toma la Captura 2:** Toma una captura de pantalla de la aplicación mostrando claramente este mensaje de rechazo o alerta de seguridad. 
   - Esta será tu **segunda captura** (Bloqueo Exitoso).
5. *(Opcional)*: Si observas la interfaz de OWASP ZAP en tu computadora, notarás que la conexión hacia `sums-api.troy.engineer` aparece bloqueada, vacía o con un error de TLS handshake, confirmando que la aplicación cortó la comunicación a nivel de red antes de enviar cualquier dato.

---

## Parte 4: Limpieza y Finalización

Una vez que tengas tus dos capturas guardadas a salvo:

1. Vuelve a los ajustes de Wi-Fi de tu celular o emulador.
2. Modifica la red y regresa la configuración del Proxy a **"Ninguno"**.
3. Guarda los cambios para que tu dispositivo recupere su conexión a internet normal.
4. Inserta las dos imágenes en tu documento LaTeX (`reporte_actividad.tex`) y genera el PDF final.

¡Listo! Con esto habrás completado exitosamente las pruebas de concepto de la actividad de seguridad.
