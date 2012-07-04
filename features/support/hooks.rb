Before do
  # Clear the uniqueness cache before each scenario.
  RawPageView.uniqueness_cache.flush_all
end