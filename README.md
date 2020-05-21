# Azure Kubernetes Service Bootstraping サンプルコード

* プライベートリポジトリでの実行をおすすめします
  * センシティブな変数はGitHubで設定したシークレットを読み込むようにしていますが、terraform planの結果がプルリクのコメントに表示されますのでご注意を
* リソース量にご注意を
  * AKSのノードプールが2つ作られます。ノードVMのタイプと数は必要に応じて調整してください
    * default: Standard_D2s_v3 * 2 (Autoscale to 5)
    * system: Standard_F2s_v2 *2
* TerraformのバックエンドはTerraform Cloudを指定しています
  * Terraform Cloud WorkspaceのExecution Modeは["Local"にします](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode)
  * 環境ごとのバックエンドファイルを用意しています
* Terraformのvariableには環境変数から渡す方針です
  * ローカル実行ではスクリプトを参考に
  * GitHubでのCIにはci.ymlのjobs.terraform.envを参考に
* Fluxを使う場合は参照先のリポジトリを指定してください
  * TF_VAR_enable_flux環境変数をtrueに
  * TF_VAR_git_authuserにレポジトリのユーザー名を (GitHub ActionsではGITHUB_ACTORを参照するようにしています)
  * TF_VAR_git_fluxrepoにレポジトリ名を
  * Fluxの[サンプルレポジトリ](https://github.com/ToruMakabe/flux-demo)
  * ブートストラップ後にfluxctl identityコマンドでシークレットを取得し、Flux用レポジトリのdeploy keyに[設定](https://docs.fluxcd.io/en/1.17.1/tutorials/get-started.html#giving-write-access)してください
* Azure Monitorのワークスペースは既にある前提で、variableに設定します
  * terraform destroyの後にログが見たい、なんてこともあるので、ワークスペースは動的に作成削除しないようにします
* masterブランチのコードで環境を再現する仕組みもあります
  * GitHubでIssueを作って"repro"というラベルを付けるとapplyが走ります
  * ラベルを外すとdestroyが走ります
  * サンプルコードでは以下に説明するsystem nodepoolの分離を行っているマシマシ版なので、時間がかかります
* Terraformが現時点で未対応の機能は、Azure CLIとkubectlで補完します
  * たとえばsystem nodepoolの指定とCritical Addonのマイグレーション
    * いずれAKSのAPIとHCLで吸収できるようになるでしょう
  * 再現環境構築ワークフローにその参考例を書いています
