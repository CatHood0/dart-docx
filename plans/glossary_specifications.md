# Especificaciones del Glosario en Office Open XML (Word)

## 1. ¿Qué es el Glosario? (Definición concreta)

| Concepto | Explicación concreta |
| :--- | :--- |
| **Nombre técnico** | Glossary Document Part |
| **Es un archivo** | Sí, un archivo XML dentro del paquete `.docx` |
| **Ubicación en el ZIP** | `/word/glossary/document.xml` |
| **Función** | Almacenar fragmentos de contenido reutilizable (texto con formato, imágenes, tablas, etc.) |
| **Sinónimos** | "Bloques de construcción", "Elementos rápidos", "Building Blocks", "AutoText" |

**En una frase:** El Glosario es una **biblioteca interna del documento** donde se guardan piezas de contenido que pueden ser reutilizadas en múltiples lugares.


## 2. Estructura del archivo del Glosario

### Archivo: `/word/glossary/document.xml`

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:glossaryDocument 
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
    
    <w:docParts>
        <!-- Cada entrada del glosario va aquí -->
        <w:docPart>
            <!-- Contenido de la entrada -->
        </w:docPart>
        
        <w:docPart>
            <!-- Otra entrada -->
        </w:docPart>
    </w:docParts>
    
</w:glossaryDocument>
```

---

## 3. Componentes del Glosario

### 3.1 `<w:glossaryDocument>` (Raíz del Glosario)

| Propiedad | Valor |
| :--- | :--- |
| **Es** | El elemento raíz del archivo `document.xml` |
| **Obligatorio** | Sí |
| **Función** | Contiene todas las entradas del glosario |

---

### 3.2 `<w:docParts>` (Lista de Entradas)

| Propiedad | Valor |
| :--- | :--- |
| **Es** | El contenedor de todas las entradas del glosario |
| **Obligatorio** | Sí |
| **Puede contener** | 0 o más elementos `<w:docPart>` |
| **Función** | Agrupar todas las entradas reutilizables |

---

### 3.3 `<w:docPart>` (Entrada Individual del Glosario)

| Propiedad | Valor |
| :--- | :--- |
| **Es** | Una pieza individual de contenido reutilizable |
| **Obligatorio** | Depende (debe existir si se referencia) |
| **Función** | Almacenar un fragmento de contenido (texto, imagen, tabla, etc.) |

**Ejemplo básico:**
```xml
<w:docPart>
    <w:docPartPr>
        <w:name w:val="MiTextoDeAyuda" />
        <w:type w:val="bbPlcHdr" />
    </w:docPartPr>
    <w:docPartBody>
        <w:p>
            <w:r>
                <w:rPr>
                    <w:i />
                    <w:color w:val="808080" />
                </w:rPr>
                <w:t>Escriba aquí...</w:t>
            </w:r>
        </w:p>
    </w:docPartBody>
</w:docPart>
```

---

### 3.4 `<w:docPartPr>` (Propiedades de la Entrada)

| Elemento | Descripción | Obligatorio |
| :--- | :--- | :--- |
| `<w:name>` | Nombre único de la entrada (identificador textual) | Sí |
| `<w:type>` | Tipo de entrada (ver tabla de tipos abajo) | No |
| `<w:category>` | Categoría para organizar entradas (ej. "Placeholders") | No |
| `<w:behavior>` | Comportamiento al insertar (sección §17.18.15) | No |
| `<w:description>` | Descripción textual de la entrada | No |

#### Tipos de entrada (`<w:type w:val="...">`)

| Valor | Significado | Uso típico |
| :--- | :--- | :--- |
| `bbPlcHdr` | **Placeholder** | Texto de ayuda para controles de contenido |
| `bbAutoText` | AutoTexto estándar | Fragmentos de texto reutilizables |
| `bbNormal` | Entrada normal | Contenido genérico |
| `bbCustomAutoText` | AutoTexto personalizado | Entradas creadas por el usuario |

---

### 3.5 `<w:docPartBody>` (Cuerpo de la Entrada)

| Propiedad | Valor |
| :--- | :--- |
| **Es** | El contenedor del contenido REAL de la entrada |
| **Puede contener** | Cualquier contenido válido de WordprocessingML (párrafos, tablas, imágenes, etc.) |
| **Función** | Almacenar el contenido que se insertará cuando se use esta entrada |

**Ejemplo con contenido complejo:**
```xml
<w:docPartBody>
    <!-- Párrafo con texto formateado -->
    <w:p>
        <w:r>
            <w:rPr>
                <w:b />
                <w:color w:val="FF0000" />
            </w:rPr>
            <w:t>¡Importante!</w:t>
        </w:r>
    </w:p>
    <!-- Tabla -->
    <w:tbl>
        <w:tblPr>
            <w:tblStyle w:val="TableGrid" />
        </w:tblPr>
        <w:tr>
            <w:tc>
                <w:p><w:r><w:t>Celda 1</w:t></w:r></w:p>
            </w:tc>
            <w:tc>
                <w:p><w:r><w:t>Celda 2</w:t></w:r></w:p>
            </w:tc>
        </w:tr>
    </w:tbl>
</w:docPartBody>
```

---

## 4. Relación entre el `sdt` y el Glosario

### Diagrama de referencia

```
┌─────────────────────────────────────────────────────────────────┐
│                         DOCUMENTO .DOCX                         │
│                                                                  │
│  ┌──────────────────────────┐    ┌──────────────────────────┐   │
│  │   CONTROL (sdt)          │    │   GLOSARIO               │   │
│  │                          │    │   (glossary/document.xml)│   │
│  │  <w:sdt>                 │    │                          │   │
│  │    <w:sdtPr>             │    │  <w:docPart>             │   │
│  │      <w:placeholder>     │    │    <w:docPartPr>         │   │
│  │        <w:docPart        │◄───│      <w:name w:val="X"/> │   │
│  │         w:val="X" />     │    │    </w:docPartPr>        │   │
│  │      </w:placeholder>    │    │    <w:docPartBody>       │   │
│  │    </w:sdtPr>            │    │      <w:t>Texto real</w:t>│   │
│  │    <w:sdtContent />      │    │    </w:docPartBody>      │   │
│  │  </w:sdt>                │    │  </w:docPart>            │   │
│  └──────────────────────────┘    └──────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Explicación de la relación

| Componente | Ubicación | Función en la relación |
| :--- | :--- | :--- |
| `<w:docPart w:val="X">` | Dentro del `sdt` | Es una **referencia** (un puntero, un enlace) a una entrada del glosario |
| `<w:docPart w:name="X">` | Dentro del glosario | Es la **definición real** del contenido |
| **Relación** | Por nombre (`w:val` = `w:name`) | El enlace apunta a la definición |

**En términos de programación:** El `sdt` contiene una **variable que almacena el ID** de una entrada, y el glosario contiene las **entradas con sus IDs**.

---

## 5. Esquema completo del Glosario

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:glossaryDocument 
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
    
    <w:docParts>
        
        <!-- ENTRADA 1: Placeholder para campo de nombre -->
        <w:docPart>
            <w:docPartPr>
                <w:name w:val="PlcHdr_Nombre" />
                <w:type w:val="bbPlcHdr" />
                <w:category w:val="Placeholders de Formulario" />
                <w:behavior w:val="p" /> <!-- p = content (se muestra el contenido) -->
            </w:docPartPr>
            <w:docPartBody>
                <w:p>
                    <w:r>
                        <w:rPr>
                            <w:i />
                            <w:color w:val="A0A0A0" />
                            <w:rFonts w:ascii="Segoe UI" />
                        </w:rPr>
                        <w:t>Nombre completo...</w:t>
                    </w:r>
                </w:p>
            </w:docPartBody>
        </w:docPart>
        
        <!-- ENTRADA 2: Placeholder para campo de fecha -->
        <w:docPart>
            <w:docPartPr>
                <w:name w:val="PlcHdr_Fecha" />
                <w:type w:val="bbPlcHdr" />
                <w:category w:val="Placeholders de Formulario" />
            </w:docPartPr>
            <w:docPartBody>
                <w:p>
                    <w:r>
                        <w:rPr>
                            <w:i />
                            <w:color w:val="A0A0A0" />
                        </w:rPr>
                        <w:t>Seleccione una fecha...</w:t>
                    </w:r>
                </w:p>
            </w:docPartBody>
        </w:docPart>
        
        <!-- ENTRADA 3: Bloque de texto reutilizable -->
        <w:docPart>
            <w:docPartPr>
                <w:name w:val="Disclaimer_Legal" />
                <w:type w:val="bbAutoText" />
                <w:category w:val="Cláusulas Legales" />
            </w:docPartPr>
            <w:docPartBody>
                <w:p>
                    <w:r>
                        <w:rPr>
                            <w:b />
                        </w:rPr>
                        <w:t>Este documento es confidencial y propiedad de...</w:t>
                    </w:r>
                </w:p>
            </w:docPartBody>
        </w:docPart>
        
    </w:docParts>
    
</w:glossaryDocument>
```

---

## 6. Referencia al Glosario desde un `sdt`

```xml
<w:sdt>
    <w:sdtPr>
        <w:text />
        <!-- Referencia al placeholder del glosario -->
        <w:placeholder>
            <w:docPart w:val="PlcHdr_Nombre" />
        </w:placeholder>
    </w:sdtPr>
    <w:sdtContent>
        <w:p><w:r><w:t /></w:r></w:p>
    </w:sdtContent>
</w:sdt>
```

**Cuando Word abre este documento:**
1.  Ve `<w:docPart w:val="PlcHdr_Nombre" />`
2.  Busca en `/word/glossary/document.xml` una entrada con `<w:name w:val="PlcHdr_Nombre">`
3.  Copia el contenido de `<w:docPartBody>` de esa entrada
4.  Lo muestra dentro del `sdt`

---

## 7. Tabla resumen de componentes

| Componente | Es un archivo | Ubicación | Contiene | Se usa para |
| :--- | :--- | :--- | :--- | :--- |
| **Glosario** | Sí | `/word/glossary/document.xml` | Lista de `docPart` | Almacenar contenido reutilizable |
| **`docParts`** | No (elemento XML) | Dentro del glosario | Múltiples `docPart` | Agrupar entradas |
| **`docPart`** | No (elemento XML) | Dentro de `docParts` | Propiedades + Cuerpo | Una entrada individual |
| **`docPartPr`** | No (elemento XML) | Dentro de `docPart` | Metadatos (nombre, tipo, categoría) | Identificar y clasificar la entrada |
| **`docPartBody`** | No (elemento XML) | Dentro de `docPart` | Contenido real (texto, tablas, etc.) | El contenido que se inserta |

---

## 8. Comportamientos de inserción (`<w:behavior>`)

Según §17.18.15 del documento:

| Valor | Comportamiento |
| :--- | :--- |
| `p` (content) | Solo se inserta el contenido, sin formato adicional |
| `s` (page) | El contenido se inserta en una nueva página (con salto de página antes) |
| `n` (nextPage) | El contenido se inserta en la página siguiente |
| `pg` (paragraphAndPage) | Se inserta un salto de página y luego el contenido |

---

## Conclusión

El Glosario es simplemente **un archivo XML más dentro del `.docx`**. No es nada mágico ni abstracto. Contiene fragmentos de contenido que pueden ser referenciados desde múltiples lugares (como los `sdt`). La referencia se hace por **nombre** (usando `<w:docPart w:val="...">`). Es un mecanismo de **reutilización de contenido** similar a tener una base de datos de plantillas dentro del propio documento.