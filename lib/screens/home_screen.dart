import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 新增這行來引用 PlatformException
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart'; // 引用新的地圖畫面
import 'rentable_map_screen.dart'; // 引用可租房屋地圖畫面

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _addressController = TextEditingController();
  // 新增一個預設的中心點給「查看預設地圖」按鈕使用
  final LatLng _defaultMapCenter = const LatLng(25.0340, 121.5645); // 例如：台北101
  bool _isLoading = false; // 新增載入狀態變數

  Future<void> _searchAndNavigate() async {
    // 在方法開始時印出輸入框的內容
    print('輸入的地址: ${_addressController.text}');

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入地址')));
      return;
    }

    setState(() {
      _isLoading = true; // 開始載入
    });

    try {
      // 實驗性：嘗試在地理編碼前設定地區，觀察是否有改善
      // 您可以取消註解下面其中一行來測試不同的地區設定
      // await setLocaleIdentifier("zh_TW"); // 嘗試設定為台灣中文
      // print('已嘗試設定地區為 zh_TW');
      // await setLocaleIdentifier("en_US"); // 嘗試設定為美國英文
      // print('已嘗試設定地區為 en_US');

      print('準備呼叫 locationFromAddress 使用地址: ${_addressController.text}');
      locationFromAddress(
            _addressController.text, // 使用控制器中的地址
          )
          .then((locations) {
            print(
              'locationFromAddress.then - Location 數量: ${locations.length}',
            );
            if (locations.isNotEmpty) {
              print('Locations 列表非空。正在處理第一個 location。');
              final location = locations.first;
              try {
                print('嘗試存取 location.latitude...');
                final double lat = location.latitude;
                print('成功存取緯度: $lat');

                print('嘗試存取 location.longitude...');
                final double lon = location.longitude;
                print('成功存取經度: $lon');

                // 檢查緯度和經度是否在有效範圍內
                if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                  print('無效的座標值: lat=$lat, lon=$lon');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('這個地址轉換出來的座標好像怪怪的，請確認地址是否正確。'),
                      ),
                    );
                  }
                  // 在 .then 內部，return 不會跳出 _searchAndNavigate
                  // 這裡應該只處理 .then 內部的邏輯
                  return;
                }

                final latLng = LatLng(lat, lon);
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(initialPosition: latLng),
                    ),
                  );
                }
              } catch (err, stackTraceInner) {
                print('內層 CATCH (then) - 座標讀取或使用錯誤: $err');
                print('內層 CATCH (then) - 錯誤類型: ${err.runtimeType}');
                print('內層 CATCH (then) - 堆疊追蹤: $stackTraceInner');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('取得的座標資料不完整，請嘗試其他地址看看。')),
                  );
                }
              }
            } else {
              print('locationFromAddress.then - 返回了一個空列表。');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('找不到這個地址耶，試試看更完整的地址或檢查一下有沒有打錯字？'),
                  ),
                );
              }
            }
          })
          .catchError((e, stackTrace) {
            print(
              'locationFromAddress.catchError - 地址轉換錯誤類型: ${e.runtimeType}',
            );
            print('locationFromAddress.catchError - 地址轉換錯誤訊息: $e');
            print('locationFromAddress.catchError - 堆疊追蹤: $stackTrace');

            String displayMessage;
            if (e is PlatformException) {
              displayMessage = '哎呀！地圖服務暫時出了點小問題，請稍後再試或檢查您的網路連線。';
            } else if (e is NoResultFoundException) {
              displayMessage = '嗯…找不到這個地址耶，試試看更完整的地址或檢查一下有沒有打錯字？';
            } else if (e is TypeError) {
              displayMessage = '這個地址格式好像不太對，可以換個方式輸入嗎？例如：台北市信義區市府路1號。';
            } else {
              displayMessage = '發生了未預期的錯誤，我們正在努力修復！請稍後再試。';
            }

            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(displayMessage)));
            }
          })
          .whenComplete(() {
            // 使用 whenComplete 來確保 _isLoading 總是在最後被設定
            if (mounted) {
              setState(() {
                _isLoading = false; // 結束載入
              });
            }
          });
    } catch (e, stackTrace) {
      // 這個 catch 主要捕捉 setLocaleIdentifier 的錯誤或 locationFromAddress 之前的同步錯誤
      print('外層 CATCH (同步錯誤) - 類型: ${e.runtimeType}');
      print('外層 CATCH (同步錯誤) - 訊息: $e');
      print('外層 CATCH (同步錯誤) - 堆疊追蹤: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('搜尋時遇到一點小狀況，請再試一次。')));
        // 如果同步操作出錯，也需要重設 isLoading
        setState(() {
          _isLoading = false;
        });
      }
    }
    // finally 區塊不再需要，因為 whenComplete 處理了 _isLoading
  }

  // 新增一個方法來導航到預設地圖位置
  void _navigateToDefaultMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(initialPosition: _defaultMapCenter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('租屋風險評估'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '輸入地址搜尋',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) =>
                  _isLoading ? null : _searchAndNavigate(), // 載入中禁用
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchAndNavigate, // 載入中禁用按鈕
              child: _isLoading
                  ? const SizedBox(
                      // 讓 CircularProgressIndicator 有固定大小
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                  : const Text('搜尋地圖位置'),
            ),
            const SizedBox(height: 10), // 在按鈕間增加一些間距
            ElevatedButton(
              onPressed: _navigateToDefaultMap, // 按下時呼叫新的方法
              child: const Text('查看預設地圖'),
            ),
            const SizedBox(height: 10), // 在按鈕間增加一些間距
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RentableMapScreen(initialPosition: _defaultMapCenter),
                  ),
                );
              },
              child: const Text('查看可租房屋地圖'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}

class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
