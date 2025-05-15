import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/influencer_dashboard/influencer_dashboard_bloc.dart';

/// A toggle button to filter by favorites
class FavoriteFilterButton extends StatefulWidget {
  /// The current user ID needed for favorite lookups
  final String userId;

  const FavoriteFilterButton({
    super.key,
    required this.userId,
  });

  @override
  State<FavoriteFilterButton> createState() => _FavoriteFilterButtonState();
}

class _FavoriteFilterButtonState extends State<FavoriteFilterButton> {
  bool _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _showOnlyFavorites
          ? BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            )
          : null,
      child: IconButton(
        icon: Icon(
          _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
        ),
        color: _showOnlyFavorites ? Colors.red : null,
        tooltip: _showOnlyFavorites
            ? 'Show all brands'
            : 'Show only favorite brands',
        onPressed: _toggleFavoriteFilter,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Get the initial state from the bloc
    final bloc = BlocProvider.of<InfluencerDashboardBloc>(context);
    _showOnlyFavorites = bloc.showOnlyFavorites;
  }

  /// Toggle between showing all brands and only favorites
  void _toggleFavoriteFilter() {
    setState(() {
      _showOnlyFavorites = !_showOnlyFavorites;
    });

    // Update the bloc
    BlocProvider.of<InfluencerDashboardBloc>(context).add(
      FilterFavoriteBrands(
        showOnlyFavorites: _showOnlyFavorites,
        userId: widget.userId,
      ),
    );
  }
}
