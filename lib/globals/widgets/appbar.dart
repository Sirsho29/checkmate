import 'package:checkmate/globals/designs/size_config.dart';
import 'package:flutter/material.dart';

class TabViewAppBar extends StatelessWidget with PreferredSizeWidget {
  final List<Tab> tabList;
  final String title;
  final bool innerBoxIsScrolled;
  const TabViewAppBar(
      {Key key,
      @required this.tabList,
      @required this.title,
      @required this.innerBoxIsScrolled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColorDark,
      leading: const Icon(Icons.navigate_before),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w400),
      ),
      pinned: true,
      floating: true,
      forceElevated: innerBoxIsScrolled,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(SizeConfig.screenWidth * 0.125),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * .02),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Theme(
              data: ThemeData(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: TabBar(
                tabs: tabList,
                labelStyle: TextStyle(
                    fontSize: SizeConfig.screenWidth * .04,
                    fontWeight: FontWeight.w400),
                isScrollable: true,
                labelColor: const Color.fromRGBO(64, 223, 159, 1),
                unselectedLabelColor: Colors.white70,
                indicatorSize: TabBarIndicatorSize.label,
                // indicator:

                // MaterialIndicator(
                //     color: const Color.fromRGBO(64, 223, 159, 1)

                //     )
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(SizeConfig.screenWidth * .25);
}

class TabViewScaffold extends StatelessWidget {
  final List<Tab> tabList;
  final List<Widget> children;
  final String title;
  final int startIndex;
  const TabViewScaffold(
      {Key key,
      @required this.tabList,
      @required this.title,
      @required this.startIndex,
      @required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, isScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ];
          },
          body: DefaultTabController(
            length: tabList.length,
            initialIndex: startIndex,
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              appBar: TabBar(
                tabs: tabList,
                labelStyle: TextStyle(
                    fontSize: SizeConfig.screenWidth * .04,
                    fontWeight: FontWeight.w800),
                unselectedLabelStyle: TextStyle(
                    fontSize: SizeConfig.screenWidth * .04,
                    fontWeight: FontWeight.w400),
                isScrollable: true,
                
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Theme.of(context).colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                // indicator: MaterialIndicator(
                //     color: const Color.fromRGBO(64, 223, 159, 1),),
              ),
              body: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0)),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return false;
                    },
                    child: TabBarView(children: children),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
