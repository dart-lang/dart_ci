import 'package:angular/angular.dart';
import 'package:angular_components/laminate/enums/alignment.dart';
import 'package:angular_forms/angular_forms.dart';

import '../formatting.dart';
import '../model/comment.dart';
import '../model/commit.dart';

@Component(
    selector: 'blamelist-panel',
    directives: [coreDirectives, formDirectives, RelativePosition],
    templateUrl: 'blamelist_component.html',
    exports: [formatted])
class BlamelistComponent {
  BlamelistComponent();

  @Input()
  List<Commit> commits;

  @Input()
  IntRange range;

  @Input()
  List<Comment> comments;

  bool collapsedBlamelist = true;

  bool showBlamelistEntry(int index) =>
      !collapsedBlamelist || index < 1 || index >= range.length - 1;
  bool showDots(int index) =>
      collapsedBlamelist && index == 1 && range.length > 2;
}
