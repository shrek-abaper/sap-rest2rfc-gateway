TYPE-POOL ytest .

TYPES:BEGIN OF ytest_testif0001_request,
        material TYPE string,
      END OF ytest_testif0001_request,
      BEGIN OF ytest_testif0001_response,
        result  TYPE string,
        message TYPE string,
      END OF ytest_testif0001_response.