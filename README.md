# PIV

Projecto de Processamento de Imagem e Visão - 4º ano 1º semestre

## Descrição

O projeto é constituído por 2 partes que se explicam de seguida:

**Parte 1**: Consiste em detetar, localizar e rastrear objetos em movimento, através de uma sequência de imagens de profundidade e de cor obtidas com um sensor Kinect estático. Para cada objeto detetado numa imagem, retornam-se as 8 coordenadas xyz, correspondentes aos vértices de uma caixa que engloba o objeto nessa imagem.

**Parte 2**: Tem o mesmo objetivo que a primeira, mas neste caso, através de uma sequência de imagens de profundidade e de cor obtidas por dois sensores Kinect estáticos. A posição relativa entre os dois sensores não é alterada. Neste caso, além das 8 coordenadas retornadas para cada objetado detetado em cada imagem, retornam-se também as matrizes de rotação e de translação entre a câmara 2 e a câmara 1.

Para a 2ª parte utilizaram-se funções (Vl_sift, ubc_match) que requerem a instalação de uma toolbox retirada do site http://www.vlfeat.org/ 
