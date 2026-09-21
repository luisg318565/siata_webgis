<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>coberturas</Name>
    <UserStyle>
      <Title>Coberturas de la Tierra CLC - IDEAM (Valle de Aburra)</Title>
      <FeatureTypeStyle>

        <Rule>
          <Title>1.1.1. Tejido urbano continuo</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>1.1.1. Tejido urbano continuo</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#CC0000</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>1.1.2. Tejido urbano discontinuo</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>1.1.2. Tejido urbano discontinuo</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#F80000</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>1.2.1. Zonas industriales o comerciales</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>1.2.1. Zonas industriales o comerciales</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#CC4D2A</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>1.2.4. Aeropuertos</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>1.2.4. Aeropuertos</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#E79C87</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>1.3.1. Zonas de extraccion minera</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>1.3.1. Zonas de extracción minera</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#A700CC</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>1.4.1. Zonas verdes urbanas</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>1.4.1. Zonas verdes urbanas</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#FF8080</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>1.4.2. Instalaciones recreativas</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>1.4.2. Instalaciones recreativas</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#FFB0B0</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>2.3.1. Pastos limpios</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>2.3.1. Pastos limpios</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#CCFFCC</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>2.3.2. Pastos arbolados</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>2.3.2. Pastos arbolados</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#9EFF9E</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>2.3.3. Pastos enmalezados</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>2.3.3. Pastos enmalezados</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#9EFFC8</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>2.4.2. Mosaico de pastos y cultivos</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>2.4.2. Mosaico de pastos y cultivos</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#FFD875</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>2.4.3. Mosaico de cultivos, pastos y espacios naturales</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>2.4.3. Mosaico de cultivos, pastos y espacios naturales</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#FFC940</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>2.4.4. Mosaico de pastos con espacios naturales</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>2.4.4. Mosaico de pastos con espacios naturales</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#FFB700</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>2.4.5. Mosaico de cultivos con espacios naturales</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>2.4.5. Mosaico de cultivos con espacios naturales</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#D69A00</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>3.1.1. Bosque denso</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>3.1.1. Bosque denso</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#478F00</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>3.1.3. Bosque fragmentado</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>3.1.3. Bosque fragmentado</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#61C200</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>3.1.4. Bosque de galeria y ripario</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>3.1.4. Bosque de galería y ripario</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#70E000</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>3.1.5. Plantacion forestal</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>3.1.5. Plantación forestal</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#80FF00</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>3.2.1. Herbazal</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>3.2.1. Herbazal</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#CCF24E</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>3.2.2. Arbustal</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>3.2.2. Arbustal</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#ACDB0F</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>3.2.3. Vegetacion secundaria o en transicion</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>3.2.3. Vegetación secundaria o en transición</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#96BF0D</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>3.3.3. Tierras desnudas y degradadas</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>3.3.3. Tierras desnudas y degradadas</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#9E9E9E</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#4D4D4D</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

        <Rule>
          <Title>5.1.3. Canales</Title>
          <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>nivel_3</ogc:PropertyName><ogc:Literal>5.1.3. Canales</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
          <PolygonSymbolizer>
            <Fill><CssParameter name="fill">#00B2FF</CssParameter></Fill>
            <Stroke><CssParameter name="stroke">#1E5A7A</CssParameter><CssParameter name="stroke-width">0.3</CssParameter></Stroke>
          </PolygonSymbolizer>
        </Rule>

      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>