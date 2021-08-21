---
title: ES 文档的API操作详情
author: Marlowe
tags:
  - ES
  - SpringBoot
  - API
categories: 中间件
abbrlink: 64325
date: 2020-12-08 19:16:02
---

...
<!--more-->

1. 编写ElasticSearchConfig 配置文件，将ES交给Spring托管

ElasticSearchConfig.java
```java
@Configuration
public class ElasticSearchConfig {

    @Bean
    public RestHighLevelClient restHighLevelClient() {
        RestHighLevelClient restHighLevelClient = new RestHighLevelClient(
                RestClient.builder(
                        new HttpHost("localhost", 9200, "http")));
        return restHighLevelClient;
    }
}
```


**ES部分API**
KuangEsApiApplicationTests.java
```java
@SpringBootTest
class KuangEsApiApplicationTests {

    @Autowired
    @Qualifier("restHighLevelClient")
    private RestHighLevelClient client;


    /**
     * 测试索引的创建 Request  PUT kuang_index
     */
    @Test
    void testCreateIndex() throws IOException {

        // 1.创建索引请求
        CreateIndexRequest request = new CreateIndexRequest("kuang_index");
        // 2.客户端执行请求 IndicesClient  请求后获得相应
        CreateIndexResponse createIndexResponse = client.indices().create(request, RequestOptions.DEFAULT);
        System.out.println(createIndexResponse);
    }

    /**
     * 测试获取索引,判断其是否存在
     */
    @Test
    void testExistsIndex() throws IOException {
        GetIndexRequest request = new GetIndexRequest("kuang_index");
        boolean exists = client.indices().exists(request, RequestOptions.DEFAULT);
        System.out.println(exists);
    }

    /**
     * 测试删除索引，判断是否存在
     *
     * @throws IOException
     */
    @Test
    void testDeleteIndex() throws IOException {
        DeleteIndexRequest request = new DeleteIndexRequest("kuang_index");
        AcknowledgedResponse delete = client.indices().delete(request, RequestOptions.DEFAULT);
        System.out.println(delete.isAcknowledged());
    }

    /**
     * 测试添加文档
     */
    @Test
    void testAddDocument() throws IOException {
        // 创建对象
        User user = new User("狂神说", 3);
        // 创建请求
        IndexRequest request = new IndexRequest("kuang_index");
        // 规则 put /kuang_index/_doc/1
        request.id("1");
        request.timeout(TimeValue.timeValueSeconds(1));
        request.timeout("1s");

        // 将我们的数据放入请求  json
        IndexRequest source = request.source(JSON.toJSONString(user), XContentType.JSON);

        // 客户端发送请求,获取响应的结果
        IndexResponse indexResponse = client.index(request, RequestOptions.DEFAULT);

        System.out.println(indexResponse.toString());
        System.out.println(indexResponse.status());
    }

    /**
     * 获取文档，判断是否存在
     */
    @Test
    void testIsExists() throws IOException {
        GetRequest getRequest = new GetRequest("kuang_index", "1");
        // 不获取返回的_source的上下文了
        getRequest.fetchSourceContext(new FetchSourceContext(false));
        getRequest.storedFields("_none_");
        boolean exists = client.exists(getRequest, RequestOptions.DEFAULT);
        System.out.println(exists);
    }

    /**
     * 获取文档的信息
     */
    @Test
    void testGetDocument() throws IOException {
        GetRequest getRequest = new GetRequest("kuang_index", "1");
        GetResponse getResponse = client.get(getRequest, RequestOptions.DEFAULT);
        // 打印文档的内容
        System.out.println(getResponse.getSourceAsString());
        // 返回的全部内容和命令是一样的
        System.out.println(getResponse);
    }

    /**
     * 更新文档的信息
     */
    @Test
    void testUpdateDocument() throws IOException {
        UpdateRequest updateRequest = new UpdateRequest("kuang_index", "1");
        updateRequest.timeout("1s");
        User user = new User("狂神说Java", 18);
        updateRequest.doc(JSON.toJSONString(user), XContentType.JSON);
        UpdateResponse updateResponse = client.update(updateRequest, RequestOptions.DEFAULT);
        System.out.println(updateResponse.status());
    }

    /**
     * 删除文档的信息
     */
    @Test
    void testDeleteDocument() throws IOException {
        DeleteRequest deleteRequest = new DeleteRequest("kuang_index", "1");
        deleteRequest.timeout("1s");
        DeleteResponse deleteResponse = client.delete(deleteRequest, RequestOptions.DEFAULT);
        System.out.println(deleteResponse);
    }


    /**
     * 批量插入数据
     */
    @Test
    void testBulkRequest() throws IOException {

        BulkRequest bulkRequest = new BulkRequest();
        bulkRequest.timeout("10s");

        List<User> userList = new ArrayList<>();
        userList.add(new User("kuangshen1", 3));
        userList.add(new User("kuangshen2", 3));
        userList.add(new User("kuangshen3", 3));
        userList.add(new User("qinjiang1", 3));
        userList.add(new User("qinjiang2", 3));
        userList.add(new User("qinjiang3", 3));

        // 批处理请求
        for (int i = 0; i < userList.size(); i++) {
            bulkRequest.add(
                    new IndexRequest("kuang_index")
                            .id("" + (i + 1))
                            .source(JSON.toJSONString(userList.get(i)), XContentType.JSON));
        }
        BulkResponse bulkResponse = client.bulk(bulkRequest, RequestOptions.DEFAULT);
        System.out.println(bulkResponse.hasFailures());
    }


    /**
     * 查询
     * searchRequest 搜索请求
     * SearchSourceBuilder  条件构造
     * HighlightBuilder   构建高亮
     * TermQueryBuilder    精确查询
     */
    @Test
    void testSearch() throws IOException {
        SearchRequest searchRequest = new SearchRequest(ESConst.ES_INDEX);
        // 构建搜索条件
        SearchSourceBuilder sourceBuilder = new SearchSourceBuilder();
        // 查询条件，我们可以使用QueryBuilder  工具来实现
        TermQueryBuilder termQueryBuilder = QueryBuilders.termQuery("name", "qinjiang1");
        sourceBuilder.query(termQueryBuilder);
        sourceBuilder.timeout(new TimeValue(60, TimeUnit.SECONDS));
        searchRequest.source(sourceBuilder);
        SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
        System.out.println(JSON.toJSONString(searchResponse.getHits()));
        System.out.println("======================");
        for (SearchHit documentFields : searchResponse.getHits().getHits()) {
            System.out.println(documentFields.getSourceAsMap());
        }
    }
}

```


