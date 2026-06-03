Un `sdt` (Structured Document Tag) es un mecanismo para agregar funcionalidad tipo "formulario" y semántica específica a un documento. Existen en varios niveles (párrafo, celda, fila, inline) y se configuran mediante un bloque de propiedades (`sdtPr`). La experiencia de usuario se mejora significativamente aplicando **estilos** (a través de `rPr` y `pPr`) al texto dentro del control, así como utilizando las propiedades integradas como texto de marcador de posición, título y bloqueo.

---

### 1. Especificaciones de los Componentes `sdt`

Un `sdt` se divide en tres partes principales, como se describe en la sección §17.5 del documento:

1.  **`<w:sdtPr>` (Propiedades del Control):** Define el tipo, comportamiento y metadatos del control de contenido.
2.  **`<w:sdtContent>` (Contenido del Control):** Contiene el contenido real del documento que se muestra dentro del control.
3.  **`<w:sdtEndPr>` (Propiedades del Carácter de Fin):** Opcional. Define propiedades de ejecución (formato de caracteres) para el marcador invisible que marca el final del control.

Los tipos de `sdt` más importantes y sus configuraciones clave son:

| Componente `sdt` (Elemento) | Tipo de Control (Ejemplo en `sdtPr`) | Propósito y Especificaciones Clave |
| :--- | :--- | :--- |
| **Rich Text** (Nivel de bloque/inline) | `<w:richText />` | Permite formato de texto enriquecido. Es el tipo más flexible. |
| **Plain Text** (Nivel de bloque/inline) | `<w:text />` | Solo texto sin formato. <br>• `<w:multiLine>`: Permite o no múltiples líneas. |
| **Combo Box** (Nivel de bloque/inline) | `<w:comboBox>` | Lista desplegable que *permite* al usuario escribir un valor personalizado. |
| **Drop-Down List** (Nivel de bloque/inline) | `<w:dropDownList>` | Lista desplegable que *no permite* valores personalizados. <br>• `<w:listItem w:value="Texto" w:displayText="Texto a Mostrar" />`: Define cada elemento de la lista. |
| **Date Picker** (Nivel de bloque/inline) | `<w:date>` | Permite seleccionar una fecha de un calendario. <br>• `<w:dateFormat>`: Define el formato de la fecha (ej. "dd/MM/yyyy").<br>• `<w:lid>`: Especifica el idioma para el calendario. |
| **Picture** (Nivel de bloque/inline) | `<w:picture>` | Permite insertar y mostrar una imagen. |
| **Building Block Gallery** (Nivel de bloque/inline) | `<w:docPartObj>` | Permite seleccionar una entrada de la galería de "Elementos rápidos" (AutoText). |
| **Group** (Nivel de bloque) | `<w:group>` | Agrupa varios otros controles para protegerlos o moverlos como una unidad. |

**Ejemplo de código para un Drop-Down List (sección §17.5.2.31):**
```xml
<w:sdt>
  <w:sdtPr>
    <w:dropDownList>
      <w:listItem w:value="Opción1" w:displayText="Primera Opción" />
      <w:listItem w:value="Opción2" w:displayText="Segunda Opción" />
    </w:dropDownList>
    <w:alias w:val="Mi Lista Desplegable" /> <!-- Nombre amigable -->
    <w:tag w:val="datos_extra" /> <!-- Metadato técnico opcional -->
  </w:sdtPr>
  <w:sdtContent>
    <w:r>
      <w:t>Primera Opción</w:t> <!-- Contenido por defecto -->
    </w:r>
  </w:sdtContent>
</w:sdt>
```

---

### 2. Mejora de la Experiencia de Usuario con Estilos

Los estilos se aplican al **contenido** del control, no al control en sí mismo. Para mejorar la UX, debes dar formato al texto dentro de `<w:sdtContent>` usando los mismos elementos de WordprocessingML que para el texto normal.

*   **Formatos de Párrafo (`<w:pPr>`):** Alineación, sangrías, espaciado.
*   **Formatos de Ejecución (`<w:rPr>`):** Fuente, tamaño, negrita, color.

#### Mejora 1: Estilos Visuales Predeterminados

Aplica un estilo visual distintivo (como el estilo "Énfasis") al texto dentro del `sdtContent` para que los usuarios identifiquen fácilmente las áreas editables.

```xml
<w:sdt>
  <w:sdtPr>
    <w:text />
    <w:label w:val="Campo de texto enriquecido"/> <!-- §17.5.2.19 -->
  </w:sdtPr>
  <w:sdtContent>
    <w:p>
      <w:pPr>
        <w:pStyle w:val="Enfasis" /> <!-- Aplica estilo de párrafo -->
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:rStyle w:val="EnfasisCar"> <!-- Aplica estilo de carácter -->
          <w:color w:val="2E74B5" /> <!-- Azul para destacar -->
        </w:rPr>
        <w:t>Texto con estilo para el usuario.</w:t>
      </w:r>
    </w:p>
  </w:sdtContent>
</w:sdt>
```

#### Mejora 2: Texto de Marcador de Posición (Placeholder)

Usa `<w:placeholder>` dentro de `<w:sdtPr>` para mostrar una guía al usuario. El formato de este texto se define en el **Glossary Document part** (sección §17.12.6-8), no directamente en el `sdt`. Asegúrate de usar `<w:docPart>` que haga referencia a una entrada de texto con el formato deseado (ej. cursiva y gris).

```xml
<w:sdtPr>
  <w:placeholder>
    <w:docPart w:val="PlaceholderTextStyle" /> <!-- Referencia a un docPart -->
  </w:placeholder>
  <w:text />
</w:sdtPr>
```

*Según la sección §2.1.195, el texto del marcador de posición no se muestra hasta que el usuario hace clic dentro y fuera del control, lo cual es crucial saber para el diseño de UX.*

#### Mejora 3: Bloqueo y Protección (Prevención de Edición)

Para controles de solo lectura o con valores fijos, usa las propiedades de bloqueo.

```xml
<w:sdtPr>
  <w:dropDownList>
    <w:listItem w:value="Aprobado" w:displayText="Aprobado" />
    <w:listItem w:value="Rechazado" w:displayText="Rechazado" />
  </w:dropDownList>
  <w:lock w:val="sdtLocked" /> <!-- §17.5.2.21: Bloquea todo el control, no se puede eliminar ni editar el contenido -->
  <!-- Otra opción: <w:lock w:val="contentLocked" /> (bloquea solo la edición del contenido, se puede eliminar el control) -->
</w:sdtPr>
```

#### Mejora 4: Configuración para `w:date` (Selector de Fecha)

Personaliza la experiencia del selector de fecha para que sea más intuitiva.

```xml
<w:sdtPr>
  <w:date>
    <w:dateFormat w:val="dd 'de' MMMM 'de' yyyy" /> <!-- Formato legible: 15 de octubre de 2023 -->
    <w:lid w:val="es-ES" /> <!-- Forzar el idioma español para el calendario -->
    <w:storeMappedDataAs w:val="dateTime" /> <!-- Almacena como fecha/hora, no como texto -->
  </w:date>
  <!-- ... placeholder, alias, etc. ... -->
</w:sdtPr>
```

### Resumen de Estilos Involucrados

| Elemento de Estilo | Ubicación | Efecto en la UX |
| :--- | :--- | :--- |
| **`<w:pStyle>`** | Dentro de `<w:pPr>` en `<w:sdtContent>` | Aplica un estilo de párrafo predefinido a todo el texto del control. |
| **`<w:rStyle>`** | Dentro de `<w:rPr>` en `<w:sdtContent>` | Aplica un estilo de carácter predefinido al texto de una ejecución. |
| **`<w:color>`, `<w:sz>`, `<w:b>`, etc.** | Dentro de `<w:rPr>` en `<w:sdtContent>` | Aplica formato directo (color, tamaño, negrita) para hacer el texto resaltar o ser más legible. |
| **`<w:placeholder>` + `<w:docPart>`** | Dentro de `<w:sdtPr>` | Muestra un texto guía (ej. "Escriba su nombre aquí") con el formato definido en la entrada del Glossary Document. |
| **`<w:lock>`** | Dentro de `<w:sdtPr>` | Protege el control (`sdtLocked` o `contentLocked`), previniendo ediciones accidentales o el borrado del propio campo. |
| **Tema del Documento** (Definido en `themePart.xml`) | A nivel de documento | Define colores y fuentes base. Los estilos aplicados a los `sdt` pueden heredar del tema (`<w:themeColor>`), asegurando consistencia visual. (§2.1.395) |

Al combinar estas especificaciones, puedes crear formularios robustos y visualmente atractivos que guíen al usuario de manera efectiva.


### Como aplicar estilos

Aplica estilos y formato directamente dentro de `<w:sdtContent>`.

### Opción 1: Usar estilos predefinidos (recomendado)

```xml
<w:sdt>
  <w:sdtPr>
    <w:text />
  </w:sdtPr>
  <w:sdtContent>
    <w:p>
      <w:pPr>
        <!-- Estilo de párrafo predefinido -->
        <w:pStyle w:val="Normal" />
      </w:pPr>
      <w:r>
        <w:rPr>
          <!-- Estilo de carácter predefinido -->
          <w:rStyle w:val="IntenseEmphasis" />
        </w:rPr>
        <w:t>Texto con estilo predefinido</w:t>
      </w:r>
    </w:p>
  </w:sdtContent>
</w:sdt>
```

### Opción 2: Aplicar formato directo (más control)

```xml
<w:sdt>
  <w:sdtPr>
    <w:text />
  </w:sdtPr>
  <w:sdtContent>
    <w:p>
      <w:r>
        <w:rPr>
          <!-- Formato directo: más control y personalización -->
          <w:b />                    <!-- Negrita -->
          <w:i />                    <!-- Cursiva -->
          <w:color w:val="2E74B5" /> <!-- Azul -->
          <w:sz w:val="28" />        <!-- Tamaño 14 puntos (28 half-points) -->
          <w:rFonts w:ascii="Calibri" />
        </w:rPr>
        <w:t>Texto con formato personalizado</w:t>
      </w:r>
    </w:p>
  </w:sdtContent>
</w:sdt>
```

## ¿Cómo aplicar formato de "marcador de posición" (texto gris)?

Puedes simular el texto de ayuda que desaparece usando formato directo. Simplemente escribe el texto de ayuda dentro del `sdtContent`.

```xml
<w:sdt>
  <w:sdtPr>
    <w:text />
  </w:sdtPr>
  <w:sdtContent>
    <w:p>
      <w:r>
        <w:rPr>
          <!-- Estilo de texto de ayuda: gris y cursiva -->
          <w:i />
          <w:color w:val="A0A0A0" />  <!-- Gris claro -->
        </w:rPr>
        <w:t>Escriba su texto aquí...</w:t>
      </w:r>
    </w:p>
  </w:sdtContent>
</w:sdt>
```

## Entonces, ¿cuándo usar el Glosario? (Solo casos avanzados)

Usa el Glosario SOLO si:

1.  El mismo texto de ayuda se repite en **decenas o cientos** de controles en diferentes documentos.
2.  Necesitas que el texto de ayuda se pueda **actualizar globalmente** desde un solo lugar.
3.  Estás construyendo un sistema de plantillas **para toda una organización**.

**Para el 99% de los casos, el Glosario es innecesario.** Aplica estilos directamente en el `sdtContent` y listo.

## Resumen práctico

| Técnica | Complejidad | Cuándo usarla |
| :--- | :--- | :--- |
| **Estilos directos en `sdtContent`** | Baja | **SIEMPRE por defecto**. Es simple, rápido y funciona perfectamente. |
| **Glosario + `docPart`** | Alta | Solo para soluciones muy grandes y profesionalizadas. |

**Mi recomendación:** Olvídate del Glosario y usa estilos directamente en el `sdtContent`. Es más fácil de implementar, más fácil de depurar y hará exactamente lo que necesitas.