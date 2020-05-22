# Azure Kubernetes Service Bootstraping サンプルコード (2020春版)

* [解説ブログ](https://torumakabe.github.io/post/aks-bootstrap-202005/)も参考に
* AKSとTerraform、Fluxの知識が前提です
* プライベートリポジトリでの実行をおすすめします
  * センシティブな変数はGitHubで設定したシークレットを読み込むようにしていますが、terraform planの結果がプルリクのコメントに表示されますのでご注意を
* Terraform実行の起点は [/src/dev](https://github.com/ToruMakabe/aks-bootstrap-202005/tree/master/src/dev) です
* リソース量にご注意を
  * AKSのノードプールが2つ作られます。ノードVMのタイプと数は必要に応じて[調整してください](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/src/modules/aks/main.tf)
    * default: Standard_D2s_v3 * 2 (Autoscale to 5)
    * system: Standard_F2s_v2 *2
* TerraformのバックエンドはTerraform Cloudを指定しています
  * Terraform Cloud WorkspaceのExecution Modeは["Local"にします](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode)
  * 環境ごとのバックエンドファイルを [/src/dev](https://github.com/ToruMakabe/aks-bootstrap-202005/tree/master/src/dev) に用意していますので、organizationを適宜変更ください
    * ローカル開発の場合にはバックエンドを指定して初期化してください

    ```bash
    terraform init -backend-config=backend-dev-local.hcl
    ```

* Terraformのvariableには環境変数から渡す方針です
  * ローカル実行では /src/scripts の下に置いた[スクリプト](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/src/scripts/setenv-dev-local-sample.sh)を参考に
  * GitHub ActionsでのCIには[ci.yml](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/.github/workflows/ci.yml)の[jobs.terraform.env](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/.github/workflows/ci.yml#L11)を参考に
* Fluxを使う場合は参照先のリポジトリを指定してください
  * TF_VAR_enable_flux環境変数をtrueに
  * TF_VAR_git_authuserにレポジトリのユーザー名を (GitHub ActionsではGITHUB_ACTORを参照するようにしています)
  * TF_VAR_git_fluxrepoにレポジトリ名を
  * Fluxの[サンプルレポジトリ](https://github.com/ToruMakabe/flux-demo)
  * ブートストラップ後にfluxctl identityコマンドでシークレットを取得し、Flux用レポジトリのdeploy keyに[設定](https://docs.fluxcd.io/en/1.17.1/tutorials/get-started.html#giving-write-access)してください
* Azure Monitorのワークスペースは既にある前提で、variableに設定します
  * クラスター削除後にログが見たい、なんてこともあるので、ワークスペースは動的に作成削除しないようにします
* AKS関連リソースが入るリソースグループ(MC_*)の外にあるリソースには、SystemAssigned指定で作られるManaged Identityから[操作する権限がない](https://docs.microsoft.com/ja-jp/azure/aks/use-managed-identity)ため、必要な場合はSystemAssignedではなくサービスプリンシパルを指定します
  * もしくはSystemAssined指定で作成したManaged Identityに必要な権限を割り当てます
  * 例: AKSを既存の別リソースグループにあるVNetに参加させる場合に、オートスケール時にサブネット操作するための権限割当が必要([参考スクリプト](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/src/scripts/assign_role_mi.sh))
  * このサンプルもVNetは別途作成していますので、オートスケールを有効にする場合にはterraform apply後に上記スクリプトで権限を割り当てください
* masterブランチのコードで環境を再現する[仕組み](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/.github/workflows/repro.yml)も置いておきます
  * GitHubでIssueを作って"repro"というラベルを付けるとterraform applyが走ります
  * ラベルを外すとdestroyが走ります
  * サンプルコードは以下に説明するsystem nodepoolの分離を行う意欲マシマシ版なので、時間がかかります
* Terraformが現時点で未対応の機能は、Azure CLIとkubectlで補完します
  * たとえば[system nodepoolの指定](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/src/scripts/update-mode-aks-nodepools.sh)、Critical Addonたちへ[nodeSelectorの指定](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/src/scripts/update-nodeselecter-system-deployments.sh)と[マイグレーション](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/src/scripts/restart-system-deployments.sh)
    * いずれAKSのAPIとHCLで吸収できると期待しています
  * 環境再現[ワークフロー](https://github.com/ToruMakabe/aks-bootstrap-202005/blob/master/.github/workflows/repro.yml)にその参考例を書いています
