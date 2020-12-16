Guia para sintese lógica utilizando os scripts deste repositório
Quaisquer duvidas, entrar em contato por cggewehr@gmail.com

ANTES DE USAR OS SCRIPTS:

  1. No script "create_project.sh", na linha 29, atribua a variavel "TEMPLATE_DIR" o caminho para o diretorio de arquivos de template, contidos neste repositorio sob a pasta "CadenceTemplate", 
  substituindo o diretorio "/home/usr/cgewehr/Desktop/CadenceTemplate" com o diretorio local de tais arquivos template.
  A partir deste diretorio serão copiados os arquivos contido neste para seus respectivos caminhos dentro da estruturação de diretorios do novo projeto a ser criado com "create_project.sh".

  2. Tome conhecimento que, para a geração automatizada de VCD, o script assume certas informações quanto ao testbench do design a ser sintetizado, sendo elas:
  
    - O arquivo VHDL deve ser denominado "testbench.vhd",
    - Não é importado nenhum pacote provido pelo usuário (Qualquer pacote que não seja da biblioteca IEEE 1164, da biblioteca padrão, ou de alguma forma provido pela ferramenta),
    - A entidade (entity) descrita neste deve ser denominada "testbench" (O nome da arquitetura é irrelevante),
    - Ao final da geração de estimulos, a simulação deve ser parada por meio de um construto com "severity failure", tal como "assert (false) severity failure" ou "report "Ending Simulation" severity failure".
    (O metodo tradicional, usando o construto "wait" sem um argumento de tempo não é suficiente para parar a simulação no simulador da Cadence).
    
    Se necessário adequar os scripts a alguma situação onde estas regras não podem ser cumpridas, as alterações necessárias provavelmente deverão ser feitas nos scripts "genVCD.tcl", para compilação/elaboração, 
    ou em "genVCD_NCSIM.in", para simulação, ambos localizados em "trunk/backend/synthesis/scripts".
    
PARA USAR OS SCRIPTS:

  1. Execute o script "create_project.sh" com argumento o diretorio onde deseja-se criar uma nova estrutura de diretorios, da forma:
  
    sh create_project.sh <PROJECT_DIR>
    
  Procure utilizar caminhos absolutos sempre que possivel para evitar possiveis complicações.
  
  2. Executado este script, dentro do diretorio desejado estará criada a estrutura de diretorios necessária a manipulação das ferramentas da Cadence, assim como os scripts de manipulação da ferramenta.
  
  3. Copie para "trunk/frontend" os arquivos fonte VHDL desejados. A rigor, esta etapa não é necessária, mas para fins de organização, recomendada.
  
  4. Em "trunk/backend/synthesis/scripts/file_list.tcl", através do comando "read_hdl", informe à ferramenta os arquivos HDL envolvidos no projeto, tal como o comentário da linha 7 de tal arquivo:
  
    read_hdl -vhdl your_source.vhd
    read_hdl -vhdl your_source_top_level.vhd
  
  Os arquivos devem ser listados em ordem "crescente", de modo que o arquivo de topo seja o ultimo a ser passado à ferramenta.
  
  5. Execute o script "run_synthesis.sh". Este script requer 6 argumentos ao total:
  
    $1: PROJECT_DIR (O mesmo diretorio passado como argumento ao script "create_project.sh" na etapa 1)
    $2: TOP_LVL_ENTITY (Entidade de topo do projeto, a entidade que de fato será sintetizada)
    $3: CLOCK_PERIOD (Periodo de clock, em nanosegundos, para qual se deseja sintetizar o design em questão)
    $4: CORNER (Corner de tensão de alimentação e temperatura usados como constraint. Para o PDK usado, "wc" corresponde a 1.62V @ 125C, "nc" a 1.8V @ 25C e "bc" a 1.98V @ -40C) ["wc", "nc", "bc"]
    $5: OPTIMIZE_FLAG (Obriga a ferramenta a realizar otimizações no design em questão) [1 para sim]
    $6: VCD_SIM_FLAG (Após a sintese, simula o design sintetizado, gera VCD e faz nova analise de potência considerando o VCD gerado) [1 para sim]
    
  6. Após esta etapa, em "trunk/backend/synthesis/deliverables_<CLOCK_PERIOD>" deverão estar os arquivos de report, assim como o design sintetizado.
