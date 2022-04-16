ExUnit.start()

Application.ensure_all_started(:mox)

Mox.defmock(ElasticsearchBehaviourMock, for: ProductsManager.Services.ElasticsearchBehaviour)
Mox.defmock(RedisBehaviourMock, for: ProductsManager.Services.RedisBehaviour)
