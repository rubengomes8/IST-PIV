# Primeira parte 

A primeira parte está dividida do seguinte modo:


### Função que faz load das imagens e depth passadas já para hsv.
  Não sei se querem ou não passar tudo para o mesmo frame e em xyz metros
  ou deixar como está, em px, e fazer isso depois.


###  Ciclo para cada frame:

  2.1 calcula o background e faz label

  2.2 calcula os vertices da caixa que está à volta do objeto

  2.3 bloco de código que adiciona as caixas à estrutura final objects(i)
  verifica todos os casos e portanto no fim nao aparece o ruído.mais detalhes no código
  
  
## Notas iniciais
  
  O código está incompleto, não me pus a copiar as funções que já estão feitas para aqui. para calcular a box meti umas dicas agora é questão de um de vocês tratar dessa parte.


1.O principal que falta fazer é o codigo que calcula o custo usando a distância e a cor. Tenho definido já um parametro que se refer ao centro de massa do objeto e calcula-se a distância a partir daí.

2.A imagem está já separada em hue, saturation e value. O value não é usado. para visualizar as imagens precisam de passar para rgb usando
    
```
 imshow(hsv2rgb(im_hsv(:,:,:,i)));
```

