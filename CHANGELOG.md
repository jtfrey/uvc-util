# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0]
Baseline release to open source.

## [1.2.0] - 2021-04-25
### Fixed
- Several issues reported with some camera's ProcessingUnit being available but unusable.  Diagnosed as the use of a static unit id of 2 for the ProcessingUnit, whereas the UVC standard has a variable unit id present in the PU header.  Added unit id map to UVCController with default unit ids for each handled unit type, overridden by unit id from the unit's header record.  User who reported issues tested the change, confirmed success.
